SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Accounting].[usp_WhoIsResponsibleForConteggio]
@ConteggioID int
AS

if not exists (select ConteggioID from Accounting.tbl_Conteggi where ConteggioID = @ConteggioID)
begin
	raiserror('Must specifY a valid ConteggioID',16,1)
	return(1)
end
--we want to see who is responsible of the creation of this snapshot and who confirm it
SELECT  SUGID.RoleName 				AS RespRole,
	SUID.FirstName + ' ' + SUID.LastName 	AS Responsible,
    c.ConteggioID, 
	st.FName			AS OperationName,
	c.GamingDate,
	GeneralPurpose.fn_UTCToLocal(1,c.ConteggioTimeUTC) as ConteggioTimeLoc
	FROM    Accounting.tbl_Conteggi c
	INNER JOIN CasinoLayout.SnapshotTypes st ON st.SnapShotTypeID = c.SnapShotTypeID 
    INNER JOIN FloorActivity.tbl_UserAccesses SUAID ON SUAID.UserAccessID = c.UserAccessID 
	INNER JOIN CasinoLayout.Users SUID ON SUAID.UserID = SUID.UserID
	INNER JOIN CasinoLayout.UserGroups SUGID ON SUAID.UserGroupID = SUGID.UserGroupID
WHERE 	c.ConteggioID = @ConteggioID
	and c.CancelID is null
GO
GRANT EXECUTE ON  [Accounting].[usp_WhoIsResponsibleForConteggio] TO [SolaLetturaNoDanni]
GO
