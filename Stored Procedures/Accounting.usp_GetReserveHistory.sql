SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Accounting].[usp_GetReserveHistory] 
@lfid int,
@ora datetime
AS

--if ora is not specified we want to know the Most Recent Reserve inserted
if @ora is null 
	set @ora = GetUTCDate()

SELECT  
	GeneralPurpose.fn_UTCToLocal(1,p.StateTime) as StateTime,
	SUM(p.Quantity*den.Denomination) AS Totale
FROM  Accounting.tbl_Progress p 
INNER JOIN Accounting.tbl_LifeCycles l ON p.LifeCycleID = l.LifeCycleID 
INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = sd.DenoID
WHERE p.LifeCycleID = @lfid
AND sd.IsRiserva = 1 --reserve 
and StateTime <= @ora
group BY GeneralPurpose.fn_UTCToLocal(1,p.StateTime)
order by GeneralPurpose.fn_UTCToLocal(1,p.StateTime) asc
GO
GRANT EXECUTE ON  [Accounting].[usp_GetReserveHistory] TO [SolaLetturaNoDanni]
GO
