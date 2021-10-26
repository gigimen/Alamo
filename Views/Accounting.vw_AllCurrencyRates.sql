SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Accounting].[vw_AllCurrencyRates]
WITH SCHEMABINDING
AS
SELECT  
	today.GamingDate, 
	today.IntRate, 
/*	Accounting.[fn_CalculateEuroRate] (
		YEA.ExtRate,
		today.ExtRate,
		today.IntRate) AS CalcIntRate,
*/	today.ExtRate, 	
	today.Note,
	YEA.ExtRate AS YeasterdayExtRate,
	YEA.IntRate AS YeasterdayIntRate,
	today.IntRate - YEA.IntRate AS RateIncrease,
	today.TableRate, 
	today.SellingRate, 
	cu.CurrencyID,
	cu.ExchangeRateMultiplier,
    cu.Isoname AS CurrencyAcronim,
    cu.bd0 AS MinDenomination,
    InsertUser.FirstName + ' ' + InsertUser.LastName AS InsertUserName,
	GeneralPurpose.fn_UTCToLocal(1,YEA.InsertTime) AS InsertTime,
	InsertSite.FName AS InsertSite,
	FixedUser.FirstName + ' ' + FixedUser.LastName AS FixedUserName,
	GeneralPurpose.fn_UTCToLocal(1,today.FixedTime) AS FixedTime,
	FixedSite.FName AS FixedSite
FROM  Accounting.tbl_CurrencyGamingdateRates today 
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = today.CurrencyID
LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates YEA ON YEA.CurrencyID = today.CurrencyID AND YEA.GamingDate = DATEADD(dd,-1,today.GamingDate) 
LEFT OUTER JOIN FloorActivity.tbl_UserAccesses InsertUserAcc 	ON InsertUserAcc.UserAccessID = YEA.InsertUserAccessID 
LEFT OUTER JOIN CasinoLayout.Users InsertUser ON InsertUserAcc.UserID = InsertUser.UserID 
LEFT OUTER JOIN CasinoLayout.Sites InsertSite ON InsertUserAcc.SiteID = InsertSite.SiteID 
LEFT OUTER JOIN FloorActivity.tbl_UserAccesses FixedUserAcc ON FixedUserAcc.UserAccessID = today.FixedUserAccessID 
LEFT OUTER JOIN CasinoLayout.Users FixedUser ON FixedUserAcc.UserID = FixedUser.UserID 
LEFT OUTER JOIN CasinoLayout.Sites FixedSite ON FixedUserAcc.SiteID = FixedSite.SiteID











GO
