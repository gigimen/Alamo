SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_GetCurrentReserve] 
@lfid int,
@oraUTC datetime,
@MRStatus int output,
@MRTime datetime output
AS
/*
DECLARE @lfid int,
@oraUTC datetime,
@MRStatus int ,
@MRTime datetime 

SET @lfid = 135913
SET @oraUTC = NULL
*/
--if ora is not specified we want to know the Most Recent Reserve inserted
IF @oraUTC IS NULL 
	SET @oraUTC = GETUTCDATE()
--PRINT @oraUTC
select @MRTime = max(StateTime)
from Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
where p.LifeCycleID = @lfid
AND sd.IsRiserva = 1 --reserve 
and StateTime <= @oraUTC
 --PRINT @MRTime

select  @MRStatus = SUM(p.Quantity*den.Denomination) 
from Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = sd.DenoID
where l.LifeCycleID = @lfid
AND sd.IsRiserva = 1 --reserve
and StateTime = @MRTime

--PRINT @MRStatus
SELECT  p.DenoID, 
	den.FDescription,
	s.Tag,
	p.Quantity, 
	p.ExchangeRate
FROM  Accounting.tbl_Progress p
inner join Accounting.tbl_LifeCycles l on p.LifeCycleID = l.LifeCycleID
INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = sd.DenoID
inner join CasinoLayout.Stocks s on s.StockID = l.StockID
WHERE p.LifeCycleID = @lfid 
and p.StateTime = @MRTime
AND sd.IsRiserva = 1 --reserve
order by p.DenoID

GO
GRANT EXECUTE ON  [Accounting].[usp_GetCurrentReserve] TO [SolaLetturaNoDanni]
GO
