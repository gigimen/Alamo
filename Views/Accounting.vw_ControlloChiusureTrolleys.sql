SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_ControlloChiusureTrolleys]
--WITH SCHEMABINDING
AS
SELECT 	
	lf.Tag,
	lf.GamingDate,
	lf.StockID,
	lf.CloseTime,
	lf.loginName,
	ISNULL(CHCar.Tot,0)			AS CL_CHCar,
	ISNULL(CHScar.Tot,0)		AS CL_CHScar,
	ISNULL(TermCar.Tot,0)		AS CL_TermCar, 
	ISNULL(TermScar.Tot,0)		AS CL_TermScar, 
	ISNULL(SP.Tot,0)			AS ShortPays,
	ISNULL(CHStamp.Tot,0)		AS Tito_CHStamp,
	ISNULL(CHLett.Tot,0)		AS Tito_CHLett,
	ISNULL(TermStamp.Tot,0)		AS Tito_TermStamp,
	ISNULL(TermLett.Tot,0)		AS Tito_TermLett,
	ISNULL(ESP.Tot,0)			AS EShortPays,
	ISNULL(ECHStamp.Tot,0)		AS ETito_CHStamp,
	ISNULL(ECHLett.Tot,0)		AS ETito_CHLett,
	ISNULL(ETermStamp.Tot,0)	AS ETito_TermStamp,
	ISNULL(ETermLett.Tot,0)		AS ETito_TermLett,
	ISNULL(JPCH.Tot,0)			AS JP_CH_Tot,
	ISNULL(JPTR.Tot,0)			AS JP_TR_Tot,
	ISNULL(JPTR.Numb,0)			AS JP_TR_Num,
	ISNULL(HP.Tot,0)			AS HandPays,
	ISNULL(EHP.Tot,0)			AS EHandPays
FROM 
--all lifecycles of the date
(
--aggiungi un commento
	SELECT l.LifeCycleID,
		l.GamingDate,
		l.Tag,
		l.StockID,
		l.CloseTime,
		l.loginName
	FROM Accounting.vw_AllStockLifeCycles l
	WHERE StockTypeID  IN(
	4,
	7
)
) lf
--cashless at terminal
LEFT OUTER JOIN 
(
SELECT  t.LifeCycleID,
	SUM(ISNULL(t.ImportoCents,0)) AS Tot
FROM Accounting.vw_AllCashlessTransactions t
WHERE t.DenoID = 66
GROUP BY t.LifeCycleID
) TermCar ON TermCar.LifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN 
(
SELECT  t.LifeCycleID,
	SUM(ISNULL(t.ImportoCents,0)) AS Tot
FROM Accounting.vw_AllCashlessTransactions t
WHERE t.DenoID = 67
GROUP BY t.LifeCycleID
) TermScar ON TermScar.LifeCycleID = lf.LifeCycleID

--cashless in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 66
) CHCar ON CHCar.LifeCycleID = lf.LifeCycleID 
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 67
) CHScar ON CHScar.LifeCycleID = lf.LifeCycleID 

--shortpay sfr in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 64
) SP ON SP.LifeCycleID = lf.LifeCycleID

--shortpay euro in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 151
) ESP ON ESP.LifeCycleID = lf.LifeCycleID

--handpay sfr in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 63
) HP ON HP.LifeCycleID = lf.LifeCycleID

--handpay euro in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 150
) EHP ON EHP.LifeCycleID = lf.LifeCycleID

--ticket sfr in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 102
) CHStamp ON CHStamp.LifeCycleID = lf.LifeCycleID 
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 103
) CHLett ON CHLett.LifeCycleID = lf.LifeCycleID

--ticket sfr sui terminali (letti da banca dati galaxis)
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 110
) TermStamp ON TermStamp.LifeCycleID = lf.LifeCycleID 
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 109
) TermLett ON TermLett.LifeCycleID = lf.LifeCycleID


--ticket euro in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 162--140
) ECHStamp ON ECHStamp.LifeCycleID = lf.LifeCycleID 
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 163--141
) ECHLett ON ECHLett.LifeCycleID = lf.LifeCycleID

--ticket sfr sui terminali (letti da banca dati galaxis)
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 167--145
) ETermStamp ON ETermStamp.LifeCycleID = lf.LifeCycleID 
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	t.DenoID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 166--144
) ETermLett ON ETermLett.LifeCycleID = lf.LifeCycleID

--jackpots in Chiusura
LEFT OUTER JOIN 
(
SELECT 	t.SourceLifeCycleID AS LifeCycleID,
	CAST(ISNULL(t.Quantity,0)*(t.Denomination * 100) AS INT) AS Tot
FROM Accounting.vw_AllTransactionDenominations t	
WHERE t.OpTypeID = 6 AND  t.DenoID = 100
) JPCH ON JPCH.LifeCycleID = lf.LifeCycleID

--jackpot transactions
LEFT OUTER JOIN 
(
SELECT  t.LifeCycleID,
	ISNULL(COUNT(*),0) AS Numb,	
	SUM(ISNULL(t.AmountCents,0)) AS Tot
FROM Accounting.vw_AllSlotTransactions t
WHERE OpTypeID = 15 --Jackpot
GROUP BY t.LifeCycleID
)JPTR ON JPTR.LifeCycleID = lf.LifeCycleID
GO
