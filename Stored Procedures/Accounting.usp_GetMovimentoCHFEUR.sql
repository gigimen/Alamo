SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO






CREATE PROCEDURE [Accounting].[usp_GetMovimentoCHFEUR] 
@LifeCycleID 	INT,
@CurrencyID		INT,
@totMov 		FLOAT 	OUT,
@EuroRate 		FLOAT 	OUT,
@utilecambio	FLOAT	OUT
AS


--run some checks before doing the real job
--first make sure it is a life cycle id of a closed stock
if @LifeCycleID is null or not exists 
(
	select LifeCycleID from Accounting.tbl_LifeCycles where Accounting.tbl_LifeCycles.LifeCycleID = @LifeCycleID
)
begin
	raiserror('Invalid Life cycle id specified',16,-1)
	RETURN (1)
END
if @CurrencyID is null or @CurrencyID NOT IN(0,4) 
begin
	raiserror('Invalid @CurrencyID specified',16,-1)
	RETURN (1)
END	


SELECT @EuroRate = IntRate FROM Accounting.tbl_CurrencyGamingdateRates
WHERE CurrencyID = 0 
AND GamingDate = (select GamingDate from Accounting.tbl_LifeCycles where Accounting.tbl_LifeCycles.LifeCycleID = @LifeCycleID)
if @EuroRate is null 
begin
	raiserror('NO Euro rate for the specified date',16,-1)
	RETURN (1)
END	
/*



declare
@LifeCycleID 	INT,
@CurrencyID		INT,
@totMov 		FLOAT 	,
@utilecambio	FLOAT	


set @LifeCycleID = 174574 
set @CurrencyID = 0


--*/

DECLARE @tmp FLOAT
SET @totMov = 0
SET @tmp = 0

--go with movimento gettoni gioco euro
--SELECT * FROM [Accounting].[vw_DailyMovimentoGettoniGiocoEuro] WHERE [LifeCycleID] = @LifeCycleID
SELECT @tmp = 
	CASE 
	WHEN @CurrencyID = 4 then
		ISNULL([GettoniToEUR],0) --chf
	ELSE
		ISNULL([EURToGettoni],0)
	END
FROM [Accounting].[vw_DailyMovimentoGettoniGiocoEuro]
WHERE [LifeCycleID] = @LifeCycleID
IF @tmp IS NOT NULL
BEGIN
	SELECT '[vw_DailyMovimentoGettoniGiocoEuro]' as 'Cosa', @tmp AS 'Qty' 
	SET @totMov = @tmp
END

--SELECT	@totMov as N'@totMov'

--go with cambi valuta euro 

--SELECT * FROM [Accounting].[vw_DailyEuroTransaction] WHERE [LifeCycleID] = @LifeCycleID
SET @tmp = 0
SELECT @tmp = 
	CASE 
	WHEN @CurrencyID = 4 THEN
		ISNULL([CHFToEUR],0)
	ELSE
		ISNULL([EURToCHF],0)
	END,
	@utilecambio = [UtileCambio]
FROM [Accounting].[vw_DailyEuroTransaction]
WHERE [LifeCycleID] = @LifeCycleID

IF @tmp IS NOT NULL
BEGIN
	SELECT '[vw_DailyEuroTransaction]' as 'Cosa', @tmp AS 'Qty' 
	SET @totMov += @tmp
end
--SELECT	@totMov as N'@totMov'

--in case of CC
IF EXISTS (
SELECT LifeCycleID FROM Accounting.vw_AllStockLifeCycles 
WHERE LifeCycleID = @LifeCycleID 
AND StockTypeID = 7 --main trolley
)
BEGIN
	SET @tmp = 0

/*
	SELECT ISNULL(SUM([CHFNetti]),0) AS CHFNEtti ,ISNULL(SUM(EuroNetti),0) AS EuroNetti
	FROM [Snoopy].[vw_AllAssegniEx]
	WHERE GamingDate = (select GamingDate from Accounting.LifeCycles where Accounting.LifeCycles.LifeCycleID = @LifeCycleID)
	AND [ContropartitaID] IN (3,4,5) --euros for chf
	AND RedemCustTransID is null --not redeemed
		AND CentaxCode is not NULL --garantito
		AND CentaxCode <> 'ng-c'
		AND CentaxCode <> 'ng'	
*/
	--go with assegni
	SELECT @tmp = 
		CASE 
		WHEN @CurrencyID = 4 THEN
--			ISNULL(SUM([CHFNetti]),0)
			ISNULL(SUM([EuroNetti]),0) * @EuroRate
		ELSE
			- ISNULL(SUM(EuroNetti),0) 
		END
	FROM [Snoopy].[vw_AllAssegniEx]
	WHERE GamingDate = (SELECT GamingDate FROM Accounting.tbl_LifeCycles WHERE Accounting.tbl_LifeCycles.LifeCycleID = @LifeCycleID)
	AND [ContropartitaID] IN (3,4,5) --euros for chf
	AND RedemCustTransID IS NULL --not redeemed
		AND CentaxCode IS NOT NULL --garantito
		AND CentaxCode <> 'ng-c'
		AND CentaxCode <> 'ng'	


	IF @tmp IS NOT NULL
	BEGIN
		SELECT '[vw_AllAssegniEx]' as 'Cosa', @tmp AS 'Qty' 
		SET @totMov += @tmp
	end
	SELECT	@totMov as N'@totMov'


END
GO
