SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Snoopy].[vw_TorneoPokerCashMov]
AS
SELECT 
	m.[PK_MovID]
	,c.CustomerID
	,c.FirstName
	,c.LastName
	,c.BirthDate
	,c.Sesso
	,m.[MoveType]
	,GeneralPurpose.fn_UTCToLocal(1,m.[TimeStampUTC]) AS Ora
	,m.[AmountCents]
	,g.[TaxCents]
	,g.[BuyInCents]
	,CAST(m.[AmountCents] AS FLOAT)/ 100.0 AS AmountEUR
	,CAST(g.[TaxCents]	  AS FLOAT)/ 100.0 AS TaxEUR
	,CAST(g.[BuyInCents]  AS FLOAT)/ 100.0 AS BuyInEUR
	,CAST(m.[AmountCents] AS FLOAT)/ 100.0 * r.IntRate AS AmountCHF
	,CAST(g.[TaxCents]	  AS FLOAT)/ 100.0 * r.IntRate AS TaxCHF
	,CAST(g.[BuyInCents]  AS FLOAT)/ 100.0 * r.IntRate AS BuyInCHF
	,m.[FK_UserAccessID]
	,m.[Progressivo]
	,[Snoopy].[fn_TorneoCheckRientro](m.[FK_TPGiornataID],m.[FK_CustomerID]) AS CheckRientro
	,g.[PK_TPGiornataID]
	,g.[FName] AS GiornoName
	,g.[FName] AS DisplayName
	,g.[GamingDate] 
	,g.[NGarantiti]
	,g.[NRientri]
	,t.[PK_TorneoID]
	,t.FName AS TorneoName
	,t.InizioIscrizioni
	,dt.PK_DayTypeID
	,dt.FName AS DayType
	,st.Tag
	,st.StockID
	,st.StockTypeID
	,lf.LifeCycleID
	,lf.GamingDate AS PagamentoGamingDate
	,r.IntRate AS euroRate 
  FROM  [Alamo].[Snoopy].[tbl_PokerTorneoCashMov] m
  INNER JOIN [CasinoLayout].[tbl_TorneiPokerGiornate] g ON g.PK_TPGiornataID = m.FK_TPGiornataID
  INNER JOIN [CasinoLayout].[tbl_TorneiPoker] t ON t.[PK_TorneoID] = g.[FK_TorneoID]
  INNER JOIN [CasinoLayout].[tbl_TorneoPokerDayType] dt ON dt.PK_DayTypeID = g.FK_DayTypeID
  INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.FK_CustomerID
  INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = m.FK_LIfeCyleID
  INNER JOIN CasinoLayout.Stocks st ON st.StockID = lf.StockID
  INNER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = lf.GamingDate AND r.CurrencyID = 0

  WHERE m.CancelID IS NULL
GO
