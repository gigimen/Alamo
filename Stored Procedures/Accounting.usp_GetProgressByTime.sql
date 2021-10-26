SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE procedure [Accounting].[usp_GetProgressByTime]
@lfid int,
@stateTimeUTC datetime
AS
/*
SELECT  
	p.DenoID, 
	den.FDescription,
	s.Tag,
	p.Quantity, 
	p.ExchangeRate
FROM  Accounting.LifeCycleProgress p
inner join Accounting.LifeCycles l on p.LifeCycleID = l.LifeCycleID
inner join CasinoLayout.Stocks s on s.StockID = l.StockID
--INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = p.DenoID
WHERE p.LifeCycleID = 182589 --@lfid 
and p.StateTime = @stateTimeUTC
and sd.IsRiserva = 0 --dont care about reserva
order by p.DenoID

*/
SELECT  p.DenoID, 
	d.FDescription,
	s.Tag,
	p.Quantity, 
	p.ExchangeRate
FROM  Accounting.tbl_Progress p
inner join CasinoLayout.Denominations d on d.DenoID = p.denoID
inner join Accounting.tbl_LifeCycles l on p.LifeCycleID = l.LifeCycleID
inner join CasinoLayout.Stocks s on s.StockID = l.StockID
WHERE p.LifeCycleID = @lfid 
and p.StateTime = @stateTimeUTC
and p.DenoID <> 93 --dont care about reserva
order by p.DenoID
GO
