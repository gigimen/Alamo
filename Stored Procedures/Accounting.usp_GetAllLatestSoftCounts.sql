SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Accounting].[usp_GetAllLatestSoftCounts] 
@GamingDate datetime output
AS
if @GamingDate is null

set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
			GetUTCDate(),
			Datediff(hh,GetUTCDAte(),GetDate()),
			1 --tables
			)

SELECT  p.LifeCycleID , 
	l.StockID,
	--l.StockCompositionID,c.IsRiserva,
	p.DenoID,
	p.Quantity, 
	GeneralPurpose.fn_UTCToLocal(1,p.StateTime) as StateTime
--	dbo.fn_GetTicHour(StateTime, @GamingDate, @hourdiff) AS TicHour
FROM   Accounting.tbl_Progress p  
inner join CasinoLayout.tbl_Denominations d on d.DenoID = p.DenoID
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN CasinoLayout.Stocks s ON l.StockID = s.StockID
inner join
(
	select P.DenoID,P.LifeCycleID,max(p.StateTime) as MaxTime 
	from Accounting.tbl_Progress P
	INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
	WHERE l.GamingDate = @GamingDate
	group by p.DenoID,p.LifeCycleID
) ulti on ulti.LifeCycleID = p.LifeCycleID and ulti.DenoID = p.DenoID and ulti.MaxTime = p.StateTime 
LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations c ON c.StockCompositionID = l.StockCompositionID AND p.DenoID = c.DenoID
WHERE s.StockTypeID = 1 
and l.GamingDate = @GamingDate
and (c.IsRiserva IS NULL OR c.IsRiserva = 0) --dont care about reserva
AND p.DenoID <> 93 --the old way to exclude stato riserva
and d.ValueTypeID <> 36 --exclude gettoni gioco euro 
order by p.LifeCycleID,p.StateTime
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllLatestSoftCounts] TO [SolaLetturaNoDanni]
GO
