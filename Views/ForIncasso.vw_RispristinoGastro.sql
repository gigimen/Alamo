SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [ForIncasso].[vw_RispristinoGastro]
AS

/**
select * from [Accounting].vw_RispristinoCasse
where gamingdate = '6.8.2020'
and RipristinoCasse <> 0
*/
SELECT [GamingDate]
      ,[Tag]
      ,[StockID]
	  --,[ValueTypeID]
      ,case 
			--when [ValueTypeID] in (2),8,9,23,24,25,26,27,28,7) then 'Banconote'
			when [ValueTypeID] in (2,3,7,40) then 'Banconote'
			when [ValueTypeID] in (1,36,42) then 'Gettoni'
			else ValueTypeName
		end as ValueTypeName
      ,[CurrencyID]
      ,[Acronim]
      ,SUM(Value) as [Value]
	  --,SUM([Ripristino]* Denomination) - SUM([Consegna] * Denomination* [ERConsegna]) as RipristinoCasse
  FROM [ForIncasso].[vw_AllConteggiSummary]
  where IsFisical = 1 and  SnapshotTypeID = 10 --and GamingDate = '6.8.2020'
  group by [Tag]
      ,[StockID]
      ,[GamingDate]
      ,[CurrencyID]
      ,[Acronim]
	  --,[ValueTypeID]
		,case 
			--when [ValueTypeID] in (2),8,9,23,24,25,26,27,28,7) then 'Banconote'
			when [ValueTypeID] in (2,3,7,40) then 'Banconote'
			when [ValueTypeID] in (1,36,42) then 'Gettoni'
			else ValueTypeName
		end

		--,[ERConsegna]
      --,ChiusuraSSID
      --,[ConsegnaTRID]
      --,[RipristinoTRID]
GO
