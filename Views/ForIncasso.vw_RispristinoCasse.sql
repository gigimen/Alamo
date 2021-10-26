SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [ForIncasso].[vw_RispristinoCasse]
AS

/**
select * from [Accounting].vw_RispristinoCasse
where gamingdate = '6.8.2020'
and RipristinoCasse <> 0
*/
SELECT [GamingDate]
      /*,[Tag]
      ,[StockID]*/
      ,case 
			--when [ValueTypeID] in (2),8,9,23,24,25,26,27,28,7) then 'Banconote'
			when [ValueTypeID] in (3,40) then 'Monete'
			when [ValueTypeID] in (1,36,42) then 'Gettoni'
			else ValueTypeName
		end as ValueTypeName
      ,[CurrencyID]
      ,[CurrencyAcronim]
      --,ChiusuraSSID
      ,SUM([Chiusura] * Denomination ) as [Chiusura]
      --,[ConsegnaTRID]
	  --,[ERConsegna]
      ,SUM([Consegna] * Denomination) as Consegna
      ,SUM([Consegna] * Denomination* [ERConsegna]) as ConsegnaCHF
      --,[RipristinoTRID]
      ,SUM([Ripristino]* Denomination) as Ripristino
      ,SUM([Ripristinato]* Denomination) as [Ripristinato]      
	  ,ISNULL(SUM([InitialQty]* Denomination),0) as [InitialQty]
	  ,SUM([Ripristino]* Denomination) - SUM([Consegna] * Denomination* [ERConsegna]) as RipristinoCasse
  FROM [Accounting].[vw_AllChiusuraConsegnaDenominations]
  where IsFisical = 1 and StockTypeID in(4,7) --and GamingDate = '6.8.2020'
  group by /*[Tag]
      ,[StockID]
      ,*/[GamingDate]
      ,[CurrencyID]
      ,[CurrencyAcronim]
		,case 
--			when [ValueTypeID] in (2,8,9,23,24,25,26,27,28,7) then 'Banconote'
			when [ValueTypeID] in (3,40) then 'Monete'
			when [ValueTypeID] in (1,36,42) then 'Gettoni'
			else ValueTypeName
		end 

		--,[ERConsegna]
      --,ChiusuraSSID
      --,[ConsegnaTRID]
      --,[RipristinoTRID]
GO
