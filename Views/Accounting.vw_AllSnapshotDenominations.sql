SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_AllSnapshotDenominations]
WITH SCHEMABINDING
AS
/*
this view allows to see all Denominations attached to a snapshot
and other informations related to the snapshot 
*/
SELECT 
	ss.LifeCycleSnapshotID, 
	ss.SnapshotTypeID, 
	sst.FName, 
	lf.LifeCycleID, 
    lf.StockID, 
	lf.GamingDate, 
	st.Tag, 
	st.StockTypeID, 
	st.MinBet,
	ss.SnapshotTime									AS SnapshotTimeUTC,
	ss.SnapshotTimeLoc, 
	conf.UserID 		AS ConfirUserID, 
    conf.UserGroupID	AS ConfirUserGroupID, 
	ua.UserID 										AS OwnerUserID, 
	ua.UserGroupID 									AS OwnerUserGroupID, 
	den.ValueTypeID, 
	vt.FName										As ValueTypeName,
	cu.CurrencyID,
	cu.IsoName										AS [CurrencyAcronim],
	cu.BD0											AS [MinDenomination],
	cu.ExchangeRateMultiplier,
	den.FDescription, 
	den.FName										As DenoName, 
    den.DenoID, 
	den.Denomination,
	den.IsFisical,
 	val.Quantity,
	val.ExchangeRate,
	comp.InitialQty,
	comp.WeightInTotal, 
	case lf.GamingDate
		when GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				st.StockTypeID) then 1
	else 0
	end as IsToday,
	case when ss.LifeCycleSnapshotID is null then 1
		else 0
	end  as IsStockOpen
FROM    Accounting.tbl_Snapshots ss
	INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID =ss.LifeCycleID  
	INNER JOIN FloorActivity.tbl_UserAccesses ua ON ua.UserAccessID =ss.UserAccessID 
	INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID 
	INNER JOIN CasinoLayout.SnapshotTypes sst ON ss.SnapshotTypeID = sst.SnapshotTypeID 
	LEFT OUTER JOIN Accounting.tbl_SnapshotValues val ON val.LifeCycleSnapshotID =ss.LifeCycleSnapshotID 
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations den	ON den.DenoID = val.DenoID
	LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes vt ON den.ValueTypeID = vt.ValueTypeID 
	LEFT OUTER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID 
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations conf ON conf.LifeCycleSnapshotID =ss.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations comp ON comp.StockCompositionID =lf.StockCompositionID and comp.DenoID = den.DenoID
WHERE  ss.LCSnapShotCancelID IS NULL
GO
