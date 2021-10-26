SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_GetAllLifeCyclesByGamingDate]
@StockTypeID int,
@gaming datetime output
AS
if @StockTypeID is null or not exists (select StockTypeID from CasinoLayout.StockTypes where StockTypeID = @StockTypeID)
BEGIN
	RAISERROR('Specify a valid StockTypeID',16,1)
	RETURN (1)
END

if @gaming is null
	set @gaming = GeneralPurpose.fn_GetGamingLocalDate2(
			GetUTCDate(),
			Datediff(hh,GetUTCDAte(),GetDate()),
			@StockTypeID
	)

SELECT  top 100 percent
	lf.LifeCycleID, 
	lf.StockID, 
	st.Tag, 
	st.StockTypeID,
	Chiusura.SnapshotTime				As CloseTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,Chiusura.SnapshotTime) 	As CloseTimeLoc, 
	Chiusura.LifeCycleSnapshotID 			as CloseSnapshotID,
	Apertura.SnapshotTime				As OpenTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,Apertura.SnapshotTime) 	As OpenTimeLoc, 
	Apertura.LifeCycleSnapshotID 			as AperturaSnapshotID,
	lf.GamingDate
/*
        dbo.fn_IsGamingDateToday(
		dbo.LifeCycles.GamingDate, 
		GetUTCDate(), 
		DATEDIFF(hh, GetUTCDate(), GETDATE()),
		dbo.Stocks.StockTypeID) AS IsToday,

	USOWN.UserID 				AS OwnerUserID,
	USOWN.FirstName + ' ' + USOWN.LastName 	as OwnerName,
	dbo.UserAccesses.UserGroupID 		AS OwnerUserGroupID,
	USCONF.UserID 				AS ConfirUserID,
	USCONF.FirstName + ' ' + USCONF.LastName as ConfirName,
	dbo.LifeCycle_Confirmations.UserGroupID AS ConfirUserGroupID
*/
FROM    Accounting.tbl_LifeCycles lf
	INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID
	INNER JOIN Accounting.tbl_Snapshots Apertura 
	ON Apertura.LifeCycleID = lf.LifeCycleID and 
	Apertura.SnapshotTypeID = 1 --'Apertura'
	--apertura has not been cancelled
	AND Apertura.LCSnapShotCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_Snapshots Chiusura 
	ON Chiusura.LifeCycleID = lf.LifeCycleID and 
	Chiusura.SnapshotTypeID  = 3 --in (select SnapshotTypeID from SnapshotTypes where FName = 'Chiusura' )
	--Chiusura has not been cancelled
	AND Chiusura.LCSnapShotCancelID IS NULL
WHERE   lf.GamingDate = @gaming
	and st.StockTypeID = @StockTypeID
order by  lf.StockID
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllLifeCyclesByGamingDate] TO [SolaLetturaNoDanni]
GO
