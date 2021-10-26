SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_GetAllSoftCountsBySite]
@GamingDate datetime,
@SiteID int
AS

--Check life cycle parameter
if (@GamingDate is null) 
	begin
		raiserror('Must specify a valid gaming date',16,-1)
		return (1)
	end
	
/*
declare
@GamingDate datetime,
@SiteID int

SET @GamingDate = '9.26.2014'
SET @SiteID = 74

DECLARE @result datetime
*/
/* old way now we have to sum up medaglie with chips estiamtion

SELECT  p.LifeCycleID , 
	l.StockID,
	p.DenoID, 
	p.Quantity, 
	p.StateTime
--	dbo.fn_GetTicHour(StateTime, @GamingDate, @hourdiff) AS TicHour
FROM    dbo.LifeCycleProgress p
INNER JOIN dbo.LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN dbo.Site_App_Stock s ON l.StockID = s.StockID
WHERE l.GamingDate = @GamingDate
and s.SiteID = @SiteID
and p.DenoID <> 93 --dont care about reserva
order by p.LifeCycleID,p.StateTime

*/


SELECT  p.LifeCycleID , 
	l.StockID,
	p.DenoID, 
	p.Quantity, 
	p.StateTime
FROM    Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = p.DenoID
INNER JOIN CasinoLayout.Site_App_Stock s ON l.StockID = s.StockID
LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND sd.DenoID = d.DenoID
WHERE l.GamingDate = @GamingDate
and s.SiteID = @SiteID
and p.DenoID not in (92,93,95,96,97) --dont care about reserva and medaglie
AND (sd.IsRiserva IS NULL OR sd.IsRiserva = 0) --ignore riserva Denominations
union all
SELECT  p.LifeCycleID , 
	l.StockID,
	92 as DenoID, --pretend their are all estimated chips
	GeneralPurpose.fn_FloorManagerRound(sum(p.Quantity * d.Denomination)/1000.0) as Quantity, --divide by a thousand
	p.StateTime
FROM    Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = p.DenoID
INNER JOIN CasinoLayout.Site_App_Stock s ON l.StockID = s.StockID
WHERE l.GamingDate = @GamingDate
and s.SiteID = @SiteID
and p.DenoID in (92,95,96,97) --add up chips e medaglie
group by p.LifeCycleID,l.StockID,p.StateTime
order by p.LifeCycleID,p.StateTime
GO
