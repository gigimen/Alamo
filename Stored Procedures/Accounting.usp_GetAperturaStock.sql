SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [Accounting].[usp_GetAperturaStock] 
@lfID INT
AS

declare @StockID int
declare @prevlfID int
declare @gaming datetime
declare @prevgaming datetime
DECLARE @EuroRate float

select @gaming = GamingDate,@StockID = StockID 
from Accounting.tbl_LifeCycles
where LifeCycleID = @lfID

SELECT @EuroRate = [IntRate] FROM Accounting.tbl_CurrencyGamingdateRates
WHERE GamingDate = @gaming AND CurrencyID = 0 --euros

if @EuroRate is null 
BEGIN
	RAISERROR('EuroRate not defined yet',16,1)
	RETURN (1)
END

/*
select @prevlfID = LifeCycleID,@prevgaming = GamingDate
from Accounting.tbl_LifeCycles
where StockID = @StockID and GamingDate in
	( 
		select max(GamingDate) 
		from Accoutning.tbl_Snapshots ss
		inner join Accounting.tbl_LifeCycles lf on lf.LifeCycleID = ss.LifeCycleID
		where lf.StockID = @StockID 
		and lf.GamingDate < @gaming 
		and ss.SnapshotTypeID = 3 --Chiusura
		and ss.LCSnapShotCancelID is null
	)
*/
select @prevlfID = lf.LifeCycleID,
@prevgaming = lf.GamingDate
from Accounting.tbl_LifeCycles	lf
inner join Accounting.tbl_Snapshots ss on lf.LifeCycleID = ss.LifeCycleID
where StockID = @StockID 
and GamingDate in
( 
		select max(GamingDate) 
		from Accounting.tbl_Snapshots ss
		inner join Accounting.tbl_LifeCycles lf on lf.LifeCycleID = ss.LifeCycleID
		where lf.StockID = @StockID 
		and lf.GamingDate < @gaming 
		and ss.SnapshotTypeID = 3 --Chiusura
		and ss.LCSnapShotCancelID is null
)
and ss.SnapshotTypeID = 1 --apertura has not been canceled
and ss.LCSnapShotCancelID is null
print @prevlfID



SELECT 	
	a.Tag,
	a.PrevGamingDate,
	a.PrevChiusuraSfr,
	a.ConsegnaSfr,
	a.RipristinoSfr,
	a.AperturaSfr,
	e.PrevChiusuraEuro,
	e.RipristinoEuro,
	e.AperturaEuro,
	e.PrevChiusuraEuroSfr,
	e.RipristinoEuroSfr,
	e.AperturaEuroSfr,
	a.PrevChiusuraSfr + e.PrevChiusuraEuroSfr AS PrevChiusura,
	a.RipristinoSfr+  e.RipristinoEuroSfr AS Ripristino,
	a.AperturaSfr + e.AperturaEuroSfr AS Apertura

FROM 
( 
--calculate Last Chiusura, Consegna and ripristino and, consequentely next apertura
SELECT  pch.Tag,
	pch.GamingDate AS PrevGamingDate,
	SUM(ISNULL(pch.Chiusura,0) * pch.Denomination * pch.ERChiusura * pch.WeightInTotal) AS PrevChiusuraSfr,
	SUM(ISNULL(pch.Consegna,0) * pch.Denomination * pch.ERConsegna * pch.WeightInTotal)  AS ConsegnaSfr,
	SUM(ISNULL(pch.Ripristino,0) * pch.Denomination * pch.ERRipristino * pch.WeightInTotal)  AS RipristinoSfr,
	SUM(ISNULL(pch.Ripristinato,0) * pch.Denomination * pch.WeightInTotal)  AS AperturaSfr
FROM Accounting.vw_AllChiusuraConsegnaDenominations pch
WHERE pch.LifeCycleID = @prevlfid AND pch.ValueTypeID NOT IN ( 7,21) --everything but euros and petty cash
GROUP BY 
	pch.Tag,
	pch.GamingDate
) a
LEFT OUTER JOIN 
(
SELECT  pch.Tag,
	pch.GamingDate AS PrevGamingDate,
	SUM(ISNULL(pch.Chiusura,0) * pch.Denomination * pch.WeightInTotal) AS PrevChiusuraEuro,
	SUM(ISNULL(pch.Ripristino,0) * pch.Denomination * pch.WeightInTotal)  AS RipristinoEuro,
	SUM(ISNULL(pch.Ripristinato,0) * pch.Denomination * pch.WeightInTotal)  AS AperturaEuro,
	SUM(ISNULL(pch.Chiusura,0) * pch.Denomination * @EuroRate * pch.WeightInTotal) AS PrevChiusuraEuroSfr,
	SUM(ISNULL(pch.Ripristino,0) * pch.Denomination* @EuroRate * pch.WeightInTotal)  AS RipristinoEuroSfr,
	SUM(ISNULL(pch.Ripristinato,0) * pch.Denomination* @EuroRate * pch.WeightInTotal)  AS AperturaEuroSfr
FROM Accounting.vw_AllChiusuraConsegnaDenominations pch
WHERE pch.LifeCycleID = @prevlfid AND pch.ValueTypeID = 7 --everything but euros
GROUP BY 
	pch.Tag,
	pch.GamingDate
)e ON e.PrevGamingDate = a.PrevGamingDate AND e.Tag = a.Tag
GO
