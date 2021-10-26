SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Accounting].[vw_CheckRipristinoMainStock]
WITH SCHEMABINDING
AS

--corretto il case

SELECT 
diff.GamingDate,
diff.[DiffCassa],
con.TotConsegna,
con.TotConsegna - diff.[DiffCassa] AS DaRipristinare,
ripT.TotRipristino AS RipristinoTavoli,
conT.TotConsegna AS ConsegnaTavoli,
ripT.TotRipristino - conT.TotConsegna AS Tavoli,
con.TotConsegna - diff.[DiffCassa] + ripT.TotRipristino - conT.TotConsegna AS TOtDaRip,
ripMS.TotalForSource AS Ripristino,
con.TotConsegna - diff.[DiffCassa] + ripT.TotRipristino - conT.TotConsegna - ripMS.TotalForSource AS Diff
from
(
	SELECT diff.GamingDate,SUM(diff.[DiffCassa]) AS diffcassa
  FROM [Accounting].[vw_AllStockDiffCassa] diff
  GROUP BY GamingDate
  ) diff
INNER JOIN 
(
select 
	lf.GamingDate,
	isNUll(SUM(conV.Quantity * conV.ExchangeRate * deno.Denomination * scd.WeightInTotal),0) as TotConsegna 
from Accounting.tbl_Transactions con 
	inner join Accounting.tbl_LifeCycles lf on con.SourceLifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
	LEFT OUTER JOIN Accounting.tbl_TransactionValues conV ON conv.TransactionID = con.TransactionID and conV.DenoID = scd.DenoID	
where con.TrCancelID is null AND con.OpTypeID = 6 --Consegna
	and deno.ValueTypeID not in 
			(1,-- 'Banconote'
				2,--'Monete'
				3,--'Gettoni'
				36, --gettoni euro
				12, --'Transazioni Cassa'
				14-- 'Transazioni Main Stock'
		)
group by lf.GamingDate

) con on con.GamingDate = diff.GamingDate
INNER JOIN 
(
select 
	lf.GamingDate,
	isNUll(SUM(conV.Quantity * conV.ExchangeRate * deno.Denomination * scd.WeightInTotal),0) as TotRIpristino
from Accounting.tbl_Transactions con 
	inner join Accounting.tbl_LifeCycles lf on con.SourceLifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
	LEFT OUTER JOIN Accounting.tbl_TransactionValues conV ON conv.TransactionID = con.TransactionID and conV.DenoID = scd.DenoID	
where con.TrCancelID is null 
	AND con.OpTypeID = 5 --ripristino
	and deno.ValueTypeID in (1,36) --'Gettoni'
	AND con.DestStockTypeID = 1
group by lf.GamingDate

) ripT on ripT.GamingDate = diff.GamingDate
INNER JOIN 
(
select 
	lf.GamingDate,
	isNUll(SUM(conV.Quantity * conV.ExchangeRate * deno.Denomination * scd.WeightInTotal),0) as TotConsegna
from Accounting.tbl_Transactions con 
	inner join Accounting.tbl_LifeCycles lf on con.SourceLifeCycleID = lf.LifeCycleID 
	inner join CasinoLayout.Stocks st on st.StockID = lf.StockID 
	INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
	LEFT OUTER JOIN Accounting.tbl_TransactionValues conV ON conv.TransactionID = con.TransactionID and conV.DenoID = scd.DenoID	
where con.TrCancelID is null 
	AND con.OpTypeID = 6 --Consegna
	and deno.ValueTypeID in (1,36) --'Gettoni'
	AND st.StockTypeID = 1
group by lf.GamingDate

) conT on conT.GamingDate = diff.GamingDate
INNER JOIN Accounting.vw_AllTransactions ripMS ON ripMS.SourceGamingDate = diff.GamingDate AND ripMS.DestStockID = 31 AND ripMS.OpTypeID = 5

WHERE abs(con.TotConsegna - diff.[DiffCassa] + ripT.TotRipristino - conT.TotConsegna - ripMS.TotalForSource) > 0.01
GO
