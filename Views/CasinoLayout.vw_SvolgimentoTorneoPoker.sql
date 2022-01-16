SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [CasinoLayout].[vw_SvolgimentoTorneoPoker]
AS
SELECT 
		t.[PK_TorneoID]
		,t.FName AS TorneoName
		,t.InizioIscrizioni
		,F.MaxDate
	  ,g.[PK_TPGiornataID]
      ,g.[FName] AS GiornoName
      ,[GamingDate]
      ,dt.PK_DayTypeID
	  ,dt.FName AS DayType
      ,[TaxCents]
      ,[BuyInCents]
      ,[NGarantiti]
	  ,[NRientri]
	  ,[EnableVincita]
  	  ,CASE WHEN [BuyInCents] IS NOT NULL THEN

	  ((((g.[FName]+ LEFT('         ',CASE WHEN f.Mlen - LEN(g.FName) < 0 THEN 0 ELSE f.Mlen - LEN(g.FName) END ))
	  + '    ' + CONVERT(VARCHAR(16),Gamingdate,105) + '    '  
	  + CONVERT([VARCHAR](8),[BuyInCents] / 100))+' + ')+CONVERT([VARCHAR](8),[TaxCents] / 100)) + ' €' 
	  
	ELSE
	  (g.[FName]+ LEFT('         ',CASE WHEN f.Mlen - LEN(g.FName) < 0 THEN 0 ELSE f.Mlen - LEN(g.FName) END ))
	  + '    ' + CONVERT(VARCHAR(16),Gamingdate,105)
	END
	  AS DisplayName
  FROM [CasinoLayout].[tbl_TorneiPokerGiornate] g
  INNER JOIN [CasinoLayout].[tbl_TorneiPoker] t ON t.[PK_TorneoID] = g.FK_TorneoID
  INNER JOIN [CasinoLayout].[tbl_TorneoPokerDayType] dt ON dt.PK_DayTypeID = g.FK_DayTypeID
  INNER JOIN 
  (
  SELECT MAX(LEN(FName)) AS Mlen,MAX(Gamingdate) AS MaxDate,FK_TorneoID FROM [CasinoLayout].[tbl_TorneiPokerGiornate]
  GROUP BY FK_TorneoID
  ) f ON f.FK_TorneoID = g.FK_TorneoID
GO
