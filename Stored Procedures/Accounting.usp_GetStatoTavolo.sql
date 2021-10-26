SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [Accounting].[usp_GetStatoTavolo] 
@lfID INT,
@oraUTC datetime
AS
/*



declare @lfID INT,
@oraUTC datetime

set @oraUTC = '10.24.2019 22:00'
set @lfID = 182630
--Tag	GamingDate	LifeCycleID
--AR14	2019-06-29 00:00:00	179484

execute [Accounting].[usp_GetStatoTavolo] @lfID ,@oraUTC 
--*/
declare @ret int
	,@StockID int
	,@StockTypeID int
	,@gaming datetime
	,@prevlfID int
	,@prevgaming datetime
	,@ultimorestime datetime
	,@penultimoRestime datetime
	,@ultimores int
	,@penultimores int
	,@incremento INT
    ,@EuroRate FLOAT
	,@MRStatus int
	,@MRTime DATETIME
    ,@percEURBox FLOAT
	,@HasGettoniEuro BIT
	,@InChiusura BIT
	,@Riserva float
    
DECLARE @dummy TABLE (deno INT,descri VARCHAR(64),Tag VARCHAR(16),q INT,er FLOAT)


if not exists ( select StockID from Accounting.tbl_LifeCycles where LifeCycleID = @lfID)
begin
	raiserror('Invalid LifeCycleID (%d)',16,1,@lfID)
	return 1
end


select 
	@gaming = l.GamingDate,
	@StockID = l.StockID ,
	@StockTypeID = s.StockTypeID
from Accounting.tbl_LifeCycles l
inner join CasinoLayout.Stocks s on s.StockID = l.StockID
where LifeCycleID = @lfID



if @StockTypeID = 1 --only for tables
BEGIN

	execute @ret = [Accounting].[usp_GetTableLastResult] 
		@lfID 
		,@ultimorestime  output
		,@penultimoRestime  output
		,@ultimores  output
		,@penultimores  output
		,@incremento  output
	if @ret <> 0 
	begin
		raiserror('Error getting last table result (%d)',16,1,@ret)
		return @ret
	end
end
	
set @HasGettoniEuro = 0


IF @oraUTC IS NULL 
	SET @InChiusura = 1
ELSE
	SET @InChiusura = 0

--mark if table handles euro
IF EXISTS (
SELECT DenoID 
FROM CasinoLayout.vw_AllStockCompositionDenominations d 
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.StockCompositionID = d.StockCompositionID 
WHERE lf.LifeCycleID = @lfID 
AND d.ValueTypeID = 42 --gettoni euro
) 
	SET @HasGettoniEuro = 1


--for debug only
--SET @HasGettoniEuro = 1



IF @HasGettoniEuro = 1
BEGIN

	SELECT @EuroRate = IntRate FROM Accounting.tbl_CurrencyGamingdateRates
	WHERE GamingDate = @gaming AND CurrencyID = 0
	if @EuroRate IS null
	begin
		raiserror('Error getting euro rate for the specified gaming date',16,1)
		return @ret
	end
END
ELSE 
	SET @EuroRate = 1.0


INSERT INTO @dummy
EXECUTE @ret = [Accounting].[usp_GetCurrentReserve] 
   @lfid
  ,@oraUTC
  ,@MRStatus OUTPUT
  ,@MRTime OUTPUT
if @ret <> 0 
begin
	raiserror('Error getting last table result (%d)',16,1,@ret)
	return @ret
end




select 
@prevlfID = lf.LifeCycleID,
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
--print @prevlfID


--calculate perc of euro in box in the last 3 months 
--for that table type
/*


declare @StockID int
declare @gaming datetime

set @StockID = 14
set @gaming = '10.24.2019'
SELECT [Accounting].[fn_PerEuroBox] (@gaming,@StockID)

--*/
IF @InChiusura = 1
	SELECT @percEURBox = [Accounting].[fn_PerEuroBox]  (@gaming,@StockID)
ELSE
	--
	SET @percEURBox = 0.0

--riserva must be adequate to the percentange of euros
IF @InChiusura = 1 and @HasGettoniEuro = 1 --if in Chiusura and we handle gettoni euro
	SET @Riserva = CAST(@MRStatus as float) *(1 + @percEURBox * (@EuroRate -1) ) 
ELSE
	SET @Riserva = CAST(@MRStatus as float)

select 	
	a.StockID,
	a.Tag,
	a.PrevGamingDate,
	a.Apertura,
	IsNull(b.Acconti,0)						AS Acconti,
	IsNull(c.Versamenti,0)					AS Versamenti,
	@ultimorestime							AS UltimoResTime,
	@ultimores								as UltimoRisultato,
	@penultimores							as PenultimoRisultato,
	@incremento								as Incremento,
	@EuroRate								AS EuroRate,
	@Riserva								AS Riserva,
	@percEURBox								AS PercEURBox,
	@HasGettoniEuro							AS HasGettoniEuro
from 
( 
	--get apertura
	select 
		pch.StockID, 
		pch.Tag,
		pch.GamingDate as PrevGamingDate,
		CASE WHEN @InChiusura = 1 THEN --we have to apply the exchange rate in Chiusura
			IsNull(sum(pch.Ripristinato * pch.Denomination	* CASE WHEN pch.CurrencyID = 0 THEN @EuroRate ELSE 1.0 end),0) 
		ELSE
			IsNull(sum(pch.Ripristinato * pch.Denomination),0)  
		END AS Apertura
	from Accounting.vw_AllChiusuraConsegnaDenominations pch
	where pch.LifeCycleID = @prevlfid and pch.ValueTypeID IN (1,36,42) --count only chips CHF and chips gioco EUR and chips EUR
	group by 
		pch.StockID, 
		pch.Tag,
		pch.GamingDate
) a
left outer join 
(
	--sum up all acconti
	select 
		SourceTag,
		SourceStockID as StockID,
		CASE WHEN @InChiusura = 1 THEN --we have to apply the exchange rate in Chiusura
			SUM(ISNULL(Quantity * Denomination * ExchangeRate * [WeightForSource],0) ) 
		ELSE 
			SUM(ISNULL(Quantity * Denomination * [WeightForSource],0) ) 
		END AS Acconti 
	from Accounting.vw_AllTransactionDenominations acc 
	where acc.SourceLifeCycleID = @lfid 
		and acc.OpTypeID = 1 
		and acc.DestLifeCycleID is not null -- accepted Acconti
		AND (@oraUTC IS NULL OR acc.SourceTimeUTC <= @oraUTC) --if ora specified must be before
	group by SourceTag,SourceStockID
) b on b.StockID = a.StockID 
left outer join (
	--sum up all versamenti
	select 
		SourceTag,
		SourceStockID as StockID,
		CASE WHEN @InChiusura = 1 THEN --we have to apply the exchange rate in Chiusura
			SUM(ISNULL(Quantity * Denomination * ExchangeRate * [WeightForSource],0) ) 
		ELSE
			SUM(ISNULL(Quantity * Denomination * [WeightForSource],0) )  
		END AS Versamenti 
	from Accounting.vw_AllTransactionDenominations ver 
	where ver.SourceLifeCycleID = @lfid 
		and ver.OpTypeID = 4 
		and ver.DestLifeCycleID is not null -- accepted Versamenti
		AND (@oraUTC IS NULL OR ver.SourceTimeUTC <= @oraUTC) --if ora specified must be before
	group by SourceTag,
	SourceStockID
) c on c.StockID = a.StockID
GO
