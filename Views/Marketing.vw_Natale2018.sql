SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Marketing].[vw_Natale2018]
WITH SCHEMABINDING
AS

SELECT     
a.CustomerID, 
[GeneralPurpose].[fn_ProperCase](cust.LastName,DEFAULT,DEFAULT)		AS LastName, 
[GeneralPurpose].[fn_ProperCase](cust.FirstName,DEFAULT,DEFAULT)	AS FirstName, 
cust.Sesso, 
cust.BirthDate, 
sec.SectorName,
[GeneralPurpose].[GroupConcat] (pre.FName)							AS Premio, 
st.FName															AS RitiratoAl,
GeneralPurpose.fn_UTCToLocal(1, a.RitiratoTimeStampUTC)		AS OraRitiro

FROM Marketing.tbl_AssegnazionePremi a 
INNER JOIN Marketing.tbl_OffertaPremi o ON a.OffertaPremioID = o.OffertaPremioID
INNER JOIN Marketing.tbl_Premi pre ON o.PremioID = pre.PremioID 
INNER JOIN Marketing.tbl_Promozioni pro ON o.PromotionID = pro.PromotionID 
INNER JOIN Snoopy.tbl_Customers cust ON a.CustomerID = cust.CustomerID 
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = cust.SectorID
LEFT OUTER JOIN CasinoLayout.Sites st ON st.SiteID = a.RitiroSiteID
WHERE a.OffertaPremioID IN (100) AND a.CancelTimeUTC IS NULL 
GROUP BY a.CustomerID, 
[GeneralPurpose].[fn_ProperCase](cust.FirstName,DEFAULT,DEFAULT), 
[GeneralPurpose].[fn_ProperCase](cust.LastName,DEFAULT,DEFAULT), 
cust.Sesso, 
cust.BirthDate,
st.FName,
GeneralPurpose.fn_UTCToLocal(1, a.RitiratoTimeStampUTC), 
sec.SectorName













GO
