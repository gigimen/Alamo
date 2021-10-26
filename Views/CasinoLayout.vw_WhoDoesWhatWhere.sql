SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [CasinoLayout].[vw_WhoDoesWhatWhere]
WITH SCHEMABINDING
AS
SELECT  
	si.SiteID, 
	si.FName AS SiteName, 
	si.ComputerName, 
	si.CashlessTerminal,
	si.AdunoTerminal,
	si.GlobalCash,	
	si.CornerBank,
	CASE 
		WHEN st.SiteTypeID = 2 THEN 1
		ELSE 0
	END  AS IsSesamEntrance	,
	CASE 
		WHEN st.SiteTypeID = 1 THEN 1
		ELSE 0
	END  AS IsCassa	,
	a.ApplicationID, 
	a.FName AS ApplicationName, 
    sto.StockID, 
	sto.Tag, 
	sto.StockTypeID
FROM CasinoLayout.Sites si 
LEFT OUTER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = si.SiteTypeID
LEFT outer JOIN CasinoLayout.Site_App_Stock sas ON si.SiteID = sas.SiteID
LEFT outer JOIN [GeneralPurpose].[Applications] a ON a.ApplicationID = sas.ApplicationID 
LEFT outer JOIN CasinoLayout.Stocks sto ON sto.StockID = sas.StockID



GO
