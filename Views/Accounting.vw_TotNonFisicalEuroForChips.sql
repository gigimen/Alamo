SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_TotNonFisicalEuroForChips] 
--WITH SCHEMABINDING
AS
SELECT 
	st.Tag,
	lf.StockID,
	st.StockTypeID,
	lf.LifeCycleID,
	lf.GamingDate,
	ISNULL(AccontiCasse.TotAccontiCasse,0) AS TotAccontiCasse,
	ISNULL(VersamentiCasse.TotVersamentiCasse,0) AS TotVersamentiCasse,
	ISNULL(VersamentiTavoli.TotVersamentiTavoli,0) AS TotVersamentiTavoli,
	ISNULL(AccontiTavoli.TotAccontiTavoli,0) AS TotAccontiTavoli,
	ISNULL(VersamentoDeposito.TotVersamentoDeposito,0) AS TotVersamentoDeposito,
	ISNULL(PrelevatoDeposito.TotPrelevatoDeposito,0) AS TotPrelevatoDeposito,
	ISNULL(EuroTrovati.TotChipsEuroTrovati,0) AS TotChipsEuroTrovati,

	--let's make the sum
	ISNULL(AccontiCasse.TotAccontiCasse,0) 
	- ISNULL(VersamentiCasse.TotVersamentiCasse,0) 
	+ ISNULL(VersamentiTavoli.TotVersamentiTavoli,0) 
	- ISNULL(AccontiTavoli.TotAccontiTavoli,0) 
	+ ISNULL(VersamentoDeposito.TotVersamentoDeposito,0) 
	- ISNULL(PrelevatoDeposito.TotPrelevatoDeposito,0) 
	+ ISNULL(EuroTrovati.TotChipsEuroTrovati,0) AS NonFisicalEuroForChips

FROM Accounting.tbl_LifeCycles lf
INNER JOIN CasinoLayout.Stocks st ON st.StockID = lf.StockID
LEFT OUTER JOIN
(
	--add acconti of chips euro from other cages
	SELECT [SourceLifeCycleID] AS LFID,ISNULL(SUM([Quantity]*[Denomination]),0) AS TotAccontiCasse
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE ValueTypeID = 36 --euro chips
	AND OpTypeID = 1 --acconto
	AND DestLifeCycleID IS NOT NULL --it has been accepted
	GROUP BY [SourceLifeCycleID]
) AccontiCasse ON AccontiCasse.LFID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--subtract versamenti of chips euro to other cages
	SELECT [SourceLifeCycleID] AS LFID,ISNULL(SUM([Quantity]*[Denomination]),0) AS TotVersamentiCasse
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE ValueTypeID = 36 --euro chips
	AND OpTypeID = 4 --versamento
	AND DestLifeCycleID IS NOT NULL --it has been accepted
	GROUP BY [SourceLifeCycleID]
) VersamentiCasse ON VersamentiCasse.LFID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--add credit of chips euro from tables
	SELECT DestLifeCycleID AS LFID,ISNULL(SUM([Quantity]*[Denomination]),0) AS TotVersamentiTavoli
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE ValueTypeID = 36 --euro chips
	AND OpTypeID = 4 --versamento
	GROUP BY DestLifeCycleID
) VersamentiTavoli ON VersamentiTavoli.LFID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--subtract fill of chips euro from tables
	SELECT DestLifeCycleID AS LFID, ISNULL(SUM([Quantity]*[Denomination]),0) AS TotAccontiTavoli
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE ValueTypeID = 36 --euro chips
	AND OpTypeID = 1 --acconto
	GROUP BY DestLifeCycleID
) AccontiTavoli ON AccontiTavoli.LFID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--add all versamenti depositi of that day
	SELECT [deponLFID] AS LFID, ISNULL(SUM(ImportoEuro),0) AS TotVersamentoDeposito
	  FROM [Snoopy].[vw_AllDepositi]
	WHERE ImportoEuro > 0 AND (DepOffLFID IS NULL  --non ancora prelevato
	OR DepOffLFID <> [deponLFID]) --prelevato un altro giorno
	GROUP BY [deponLFID]
) VersamentoDeposito ON VersamentoDeposito.LFID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--add all prelevamenti da depositi of the day
	SELECT[depoffLFID] AS LFID, ISNULL(SUM(ImportoEuro),0) AS TotPrelevatoDeposito
	  FROM [Snoopy].[vw_AllDepositi]
	WHERE ImportoEuro > 0 AND  [DepOnGamingdate] < [DepOffGamingdate] --versato in un giorno precedente
	GROUP BY [depoffLFID]
)PrelevatoDeposito ON PrelevatoDeposito.LFID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--add also all chips euro trovati
	SELECT [LifeCycleID] AS LFID ,ISNULL([Bilancio],0) AS TotChipsEuroTrovati
	FROM [Snoopy].[vw_FluttuazioneChipsEuroTrovato]
) EuroTrovati ON EuroTrovati.LFID = lf.LifeCycleID


GO
