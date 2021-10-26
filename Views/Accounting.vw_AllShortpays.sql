SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Accounting].[vw_AllShortpays]
with schemabinding
AS
SELECT [SourceGamingDate] as GamingDate
      ,sum([Quantity] * Denomination) as Amount
      ,denoid
	  ,[DenoName]
  FROM [Accounting].[vw_AllTransactionDenominations]
  where datepart(year,SourceGamingDate) = 2016 and denoid in(151,64)
  group by  [SourceGamingDate]
      ,denoid
	  ,[DenoName]
GO
