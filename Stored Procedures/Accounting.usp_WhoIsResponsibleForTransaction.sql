SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_WhoIsResponsibleForTransaction]
@transID int
AS
if not exists (select TransactionID from Accounting.tbl_Transactions where TransactionID = @transID and TrCancelID is null)
begin
	raiserror('Must specifY a valid transaction ID',16,1)
	return(1)
end
--we want to see who is responsible of the creation of this transaction and who confirm it
SELECT  SUID.UserID				As SourceUserID,
	SUGID.RoleName 				As SourceRespRole,
	SUID.FirstName + ' ' + SUID.LastName 	AS SourceResponsible,
	SCUGID.RoleName 			AS SourceConfRole,
	SCUID.FirstName + ' ' + SCUID.LastName 	AS SourceConfirmator,
        DUID.UserID				As DestUserID,
	DUGID.RoleName 				As DestRespRole,
	DUID.FirstName + ' ' + DUID.LastName 	AS DestResponsible,
	DCUGID.RoleName 			AS DestConfRole,
	DCUID.FirstName + ' ' + DCUID.LastName 	AS DestConfirmator,
    CasinoLayout.OperationTypes.FName		AS OperationName,
	Accounting.tbl_Transactions.SourceTime		AS SourceTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,Accounting.tbl_Transactions.SourceTime) AS SourceTimeLoc, 
	Accounting.tbl_LifeCycles.GamingDate		AS SourceGamingDate
	FROM    Accounting.tbl_Transactions 
        INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Transactions.SourceLifeCycleID 
        INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID 
        INNER JOIN FloorActivity.tbl_UserAccesses SUAID ON SUAID.UserAccessID = Accounting.tbl_Transactions.SourceUserAccessID 
	INNER JOIN CasinoLayout.Users SUID ON SUAID.UserID = SUID.UserID
	INNER JOIN CasinoLayout.UserGroups SUGID ON SUAID.UserGroupID = SUGID.UserGroupID
	LEFT OUTER JOIN Accounting.tbl_Transaction_Confirmations STCONF ON (Accounting.tbl_Transactions.TransactionID = STCONF.TransactionID  and STCONF.IsSourceConfirmation = 1)
	LEFT OUTER JOIN CasinoLayout.Users SCUID ON SCUID.UserID = STCONF.UserID
	LEFT OUTER JOIN CasinoLayout.UserGroups SCUGID ON SCUGID.UserGroupID = STCONF.UserGroupID
	--join also for the destination user access
        LEFT OUTER JOIN FloorActivity.tbl_UserAccesses 	DUAID  ON DUAID.UserAccessID 	= Accounting.tbl_Transactions.DestUserAccessID 
	LEFT OUTER JOIN CasinoLayout.Users 		DUID   ON DUAID.UserID 		= DUID.UserID
	LEFT OUTER JOIN CasinoLayout.UserGroups 		DUGID  ON DUAID.UserGroupID 	= DUGID.UserGroupID
	LEFT OUTER JOIN Accounting.tbl_Transaction_Confirmations DTCONF ON (Accounting.tbl_Transactions.TransactionID = DTCONF.TransactionID  and DTCONF.IsSourceConfirmation = 0)
	LEFT OUTER JOIN CasinoLayout.Users 		DCUID  ON DCUID.UserID 		= DTCONF.UserID
	LEFT OUTER JOIN CasinoLayout.UserGroups 		DCUGID ON DCUGID.UserGroupID 	= DTCONF.UserGroupID
WHERE 	Accounting.tbl_Transactions.TransactionID = @transID
	and Accounting.tbl_Transactions.TrCancelID is null
	
GO
GRANT EXECUTE ON  [Accounting].[usp_WhoIsResponsibleForTransaction] TO [SolaLetturaNoDanni]
GO
