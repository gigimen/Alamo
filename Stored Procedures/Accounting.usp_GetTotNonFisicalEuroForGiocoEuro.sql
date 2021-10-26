SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_GetTotNonFisicalEuroForGiocoEuro] 
@lfid int,
@TotNonFisicalEuroForChips float output,
@TotNonFisicalEuroForTickets float output,
@TotNonFisicalEuroForCashless float output
AS

if not exists (select GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @lfid)
begin
	raiserror('Invalid LifeCycleID %d specified',16,1,@lfid)
	return (2)
END

SET @TotNonFisicalEuroForChips = 0
SET @TotNonFisicalEuroForTickets = 0
SET @TotNonFisicalEuroForCashless = 0


select @TotNonFisicalEuroForChips = NonFisicalEuroForChips
from [Accounting].[vw_TotNonFisicalEuroForChips] 
where LifeCycleID = @lfid
/*
--in case of main cassa add also assegni
IF EXISTS (SELECT StockID FROM Accounting.LifeCycles WHERE LifeCycleID = @lfid AND StockID = 46)
BEGIN
	SELECT  @TotNonFisicalEuroForTickets += ISNULL(SUM(EuroNetti),0)
	from [Snoopy].[vw_AllAssegni]
	where GamingDate in ( select GamingDate from Accounting.LifeCycles where LifeCycleID = @lfid )
	and CentaxCode <> 'NG'
	and CentaxCode <> 'NG-C'
	and RedemCustTransID is NULL
	AND PrelievoEuro = 1
END
*/
--tickets and cashless are only from bonifici
/*
SELECT @TotNonFisicalEuroForTickets = ISNULL(SUM(CHF),0)
	FROM [Snoopy].[vw_AllBonifici]
WHERE [IsFromEuroCredits] = 1 AND CashoutType = 2 --ticket cashout
AND [ORDERLFID] = @lfid


--tickets and cashless are only from bonifici
SELECT @TotNonFisicalEuroForCashless = ISNULL(SUM(CHF),0)
	FROM [Snoopy].[vw_AllBonifici]
WHERE [IsFromEuroCredits] = 1 AND CashoutType = 3 --cashless cashout
AND [ORDERLFID] = @lfid
*/
return 0

/*
--look for assegni that has been used to buy chips
SELECT @TotNonFisicalEuroForChips = ISNULL(SUM([Importo]),0)
from [Snoopy].[vw_AllAssegni]
where GamingDate in ( select GamingDate from Accounting.LifeCycles where LifeCycleID = @lfid )
and CentaxCode <> 'NG'
and CentaxCode <> '"NG-C'
and RedemCustTransID is NULL
AND CauseID = 16

--look for aduno transactions used to buy chips
SELECT @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips + ISNULL(SUM([Quantity]*[Denomination]),0)
from [Accounting].[vw_AllCartediCredito]
where GamingDate in ( select GamingDate from Accounting.LifeCycles where LifeCycleID = @lfid )
AND CauseID = 16
AND DenoID = 99 --ADuno €

*/

DECLARE @chips float



--add acconti of chips euro from other cages
SELECT @chips = ISNULL(SUM([Quantity]*[Denomination]),0)
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE [SourceLifeCycleID] = @lfid -- i am the source of acconto
AND ValueTypeID = 36 --euro chips
AND OpTypeID = 1 --acconto
AND DestLifeCycleID IS NOT NULL --it has been accepted
PRINT 'acconti ad altri stock ' + CAST(@chips AS varchar(32))
SET @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips + @chips 

--subtract versamenti of chips euro to other cages
SELECT @chips = ISNULL(SUM([Quantity]*[Denomination]),0)
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE [SourceLifeCycleID] = @lfid -- i am the source of versamento
AND ValueTypeID = 36 --euro chips
AND OpTypeID = 4 --versamento
AND DestLifeCycleID IS NOT NULL --it has been accepted
PRINT 'versamenti ad altri stock ' + CAST(@chips AS varchar(32))
SET @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips - @chips



--add credit of chips euro from tables
SELECT @chips = ISNULL(SUM([Quantity]*[Denomination]),0)
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE DestLifeCycleID = @lfid -- i am the destination of versamento
AND ValueTypeID = 36 --euro chips
AND OpTypeID = 4 --versamento
PRINT 'versamenti da altri stock ' + CAST(@chips AS varchar(32))
SET @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips + @chips 

--subtract fill of chips euro from tables
SELECT @chips = ISNULL(SUM([Quantity]*[Denomination]),0)
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE DestLifeCycleID = @lfid -- i am the source of versamento
AND ValueTypeID = 36 --euro chips
AND OpTypeID = 1 --acconto
PRINT 'acconti da altri stock ' + CAST(@chips AS varchar(32))
SET @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips - @chips





--add all versamenti depositi of the day
SELECT @chips = ISNULL(SUM(ImportoEuro),0) 
  FROM [Snoopy].[vw_AllDepositi]
WHERE [DepOnLFID] = @lfid --depositato oggi 
AND DepOffLFID IS NULL --non ancora prelevato
PRINT 'versamenti in deposito ' + CAST(@chips AS varchar(32))
SET @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips + @chips

--add all prelevamenti da depositi of the day
SELECT @chips = ISNULL(SUM(ImportoEuro),0) 
  FROM [Snoopy].[vw_AllDepositi]
WHERE [DepOffLFID] = @lfid --prelevato oggi
AND [DepOnGamingDate] < [DepOffGamingDate] --versato in un giorno precedente
PRINT 'prelevamenti da deposito ' + CAST(@chips AS varchar(32))
SET @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips - @chips

--add also all chips euro trovati
SELECT @chips = ISNULL([Bilancio],0)
FROM [Snoopy].[vw_FluttuazioneChipsEuroTrovato]
WHERE [LifeCycleID] = @lfid
PRINT 'bilancio movimenti denaro trovato ' + CAST(@chips AS varchar(32))
set @TotNonFisicalEuroForChips = @TotNonFisicalEuroForChips + @chips
GO
