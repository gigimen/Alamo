SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE function [ForIncasso].[fn_GetConteggioGastro] (@gaming datetime)
RETURNS   @gastro TABLE(
	[ForIncassoTag] VARCHAR(64),
	[Amount]	FLOAT)
AS
BEGIN

INSERT INTO @gastro
(
	[ForIncassoTag],
	[Amount]
)

/*
declare @gaming datetime

set @gaming = '1.23.2022'
select * from [ForIncasso].[fn_GetConteggioGastro] (@gaming )

--*/
SELECT 
	'GASTRO_COUNTED_' + CurrencyAcronim + '_'  + UPPER(Tag) AS 'ForIncassoTag',
	SUM(Quantity*Denomination) AS Amount
FROM Accounting.vw_AllConteggiDenominations
WHERE SnapshotTypeID = 10 AND gamingdate = @gaming
GROUP BY CurrencyAcronim,Tag



/*



declare @gaming datetime
declare @gastro TABLE(
	[ForIncassoTag] VARCHAR(64),
	[Amount]	FLOAT)
set @gaming = '1.24.2022'

--*/

INSERT INTO @gastro ([ForIncassoTag],[Amount]) 
SELECT 'GASTRO_FONDO_RISTO_CHF' AS 'ForIncassoTag',TotaleCHF AS Amount 
FROM  CasinoLayout.vw_VariazioniInitialStock a
WHERE a.StockID = 65 AND @gaming >= StartOfUseGamingDate AND (EndOfUseGamingdate IS NULL OR @gaming <= EndOfUseGamingdate)

INSERT INTO @gastro ([ForIncassoTag],[Amount]) 
SELECT 'GASTRO_FONDO_BAR_CHF' AS 'ForIncassoTag',TotaleCHF AS Amount 
FROM  [CasinoLayout].[vw_AllStockCompositionTotalsByCurrency] a
WHERE a.StockID = 67 AND @gaming >= StartOfUseGamingDate AND (EndOfUseGamingdate IS NULL OR @gaming <= EndOfUseGamingdate)

INSERT INTO @gastro ([ForIncassoTag],[Amount]) 
SELECT 'GASTRO_FONDO_RISTO_EUR' AS 'ForIncassoTag',TotaleEUR AS Amount 
FROM  [CasinoLayout].[vw_AllStockCompositionTotalsByCurrency] a
WHERE a.StockID = 65 AND @gaming >= StartOfUseGamingDate AND (EndOfUseGamingdate IS NULL OR @gaming <= EndOfUseGamingdate)


INSERT INTO @gastro ([ForIncassoTag],[Amount]) 
SELECT 'GASTRO_FONDO_BAR_EUR' AS 'ForIncassoTag',TotaleEUR AS Amount 
FROM  CasinoLayout.vw_VariazioniInitialStock a
WHERE a.StockID = 67 AND @gaming >= StartOfUseGamingDate AND (EndOfUseGamingdate IS NULL OR @gaming <= EndOfUseGamingdate)


DECLARE  @incrCHF INT,@incrEUR INT

--cerca per incrementi di fondo cassa per il giorno dopo
SET @gaming = DATEADD(DAY,1,@gaming)


SELECT @incrEUR = SUM (ISNULL(IncrementoEUR,0)),@incrchf= SUM(ISNULL(IncrementoCHF,0)) 
FROM  CasinoLayout.vw_VariazioniInitialStock a
WHERE @gaming = StartOfUseGamingDate

--SELECT  @incrCHF,@incrEUR

IF @incrCHF <> 0
	INSERT INTO @gastro ([ForIncassoTag],[Amount]) SELECT 'GASTRO_FLUTT_FC_CHF' AS 'ForIncassoTag',@incrCHF AS Amount 



IF @incrEUR <> 0
	INSERT INTO @gastro ([ForIncassoTag],[Amount]) SELECT 'GASTRO_FLUTT_FC_EUR' AS 'ForIncassoTag',@incrEUR AS Amount 

--SELECT * FROM @gastro


RETURN 
END
GO
