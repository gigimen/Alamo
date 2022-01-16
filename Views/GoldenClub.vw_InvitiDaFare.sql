SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [GoldenClub].[vw_InvitiDaFare]
AS
   SELECT TOP 1000 
      g.[CustomerID]
	  ,g.Categoria
	  ,ISNULL(COUNT(i.[InvitoID]) ,0) AS NumInviti 
	  ,p.wday
	  ,g.SMSNumber
  FROM GoldenClub.tbl_Members g
  LEFT OUTER JOIN GoldenClub.tbl_InvitiCene i ON g.CustomerID = i.CustomerID
  LEFT OUTER JOIN Reception.vw_AllGoldenGiorniPreferiti p ON p.customerid = g.CustomerID
  WHERE g.SMSNumber IS NOT NULL 
  AND g.GoldenParams & 1 = 0 --con sms valido
  AND g.GoldenParams & 256 = 256 --inviti cene è valido
  AND g.CancelID IS NULL --non ha rinunciato
  AND g.Categoria < 4 AND (i.GamingDate IS NULL OR i.GamingDate >= GETDATE() - 180 )
  GROUP BY 
	g.CustomerID
	,g.Categoria
	,p.wday
	,g.SMSNumber
  --aventi meno di 5 inviti negli ultimi 180 giorni
  HAVING ISNULL(COUNT(i.[InvitoID]) ,0) < 5
  ORDER BY ISNULL(COUNT(i.[InvitoID]) ,0) ASC,g.Categoria ASC







GO
