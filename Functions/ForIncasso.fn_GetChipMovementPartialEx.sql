SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [ForIncasso].[fn_GetChipMovementPartialEx]
(
    @gaming DATETIME,
	@oggi VARCHAR(16),
	@includeLucky BIT = 0
)
/*

select * from [ForIncasso].[fn_GetChipMovementPartialEx] ('4.5.2020','IERI')
select * from [ForIncasso].[fn_GetChipMovementPartialEx] ('4.6.2020','OGGI',1)

*/
RETURNS @RifList TABLE (ForIncassoTag VARCHAR(32) PRIMARY KEY CLUSTERED, Amount INT)
--WITH SCHEMABINDING
AS
BEGIN

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('4.4.2019' ,'OGGI',DEFAULT)
 execute [ForIncasso].[usp_ChipMovement] '5.3.2019' ,'IERI'
 

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '6.23.2019'
set 	@oggi = 'OGGI'


--*/

DECLARE @luckyDenoID INT
SET @luckyDenoID = 0

IF @includeLucky = 0
	SET @luckyDenoID = 78
/************************	
*						*
*	     TAVOLI			*
*						*
*************************/
INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)


/*

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '2.10.2020'
set 	@oggi = 'OGGI'
--*/
SELECT 	'CHIPMOV_' + Acronim + '_' + @oggi + '_TAV_' + cast ([ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS VARCHAR(16) ) AS ForIncassoTag,
SUM(Chiusura) + SUM(Ripristino) AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,1) --TAVOLI
WHERE ValueTypeID NOT IN (36) AND DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),Acronim




/************************	
*						*
*	     SMT			*
*						*
*************************/
INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
/*


DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '2.10.2020'
set 	@oggi = 'OGGI'

--*/
SELECT 	'CHIPMOV_' + Acronim + '_' + @oggi + '_SMT_' + cast ([ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS VARCHAR(16) ) AS ForIncassoTag,
SUM(Chiusura) + SUM(Ripristino) AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,3)  --SMT
WHERE ValueTypeID NOT IN (36)  AND DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),Acronim


/************************************	
*									*
*	     MAINSTOCK					*
*	temp table						*
* perché magari non è ancora chiuso *
*************************************/

DECLARE @MSStatus TABLE (DenoID INT, Acronim VARCHAR(4), Amount INT)
DECLARE @CloseSnapshotID int
--se MS è stato chiuso usa la funzione [ForIncasso].[fn_GetChipsRipristinati]
SELECT @CloseSnapshotID = [ForIncasso].[fn_IsMainStockOpen] (@gaming)
IF @CloseSnapshotID <> 0 --E' chiuso o non è stato aperto: in questo caso prendi i valori dall'ultima chiusura
BEGIN

	INSERT INTO @MSStatus
	(
		DenoID,
		Acronim,
		Amount
	)
/*



DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '3.18.2020'
set 	@oggi = 'OGGI'
select * from  [ForIncasso].[fn_GetChipsRipristinati] (@gaming,2)
order by DenoID
--*/	
--*/
	SELECT 	
	[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,
	[ForIncasso].[fn_AcronimEx](ValueTypeID)		AS Acronim,
	SUM(Chiusura) + SUM(Ripristino)					AS Amount
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,2)  --MS
	WHERE DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)

END
ELSE
BEGIN
	--è ancora aperto: prendi i valori dallo stato corrente
	INSERT INTO @MSStatus
	(
		DenoID,
		Acronim,
		Amount
	)
	SELECT 	
	[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,
	[ForIncasso].[fn_AcronimEx](ValueTypeID)		AS Acronim,
	Stato											AS Amount
	FROM [Accounting].[fn_GetMainStockChipStatus] ()
	WHERE  DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
END



/************************************	
*									*
*	     RISERVA					*
*	temp table						*
* perché magari non è ancora chiusa *
*************************************/

DECLARE @RisStatus TABLE (DenoID INT, Acronim VARCHAR(4), Amount INT)
--se MS è stato chiuso usa la funzione [ForIncasso].[fn_GetChipsRipristinati]
SELECT @CloseSnapshotID = [ForIncasso].[fn_IsRiservaOpen] (@gaming)
IF @CloseSnapshotID <> 0 --E' chiuso o non è stato aperto: in questo caso prendi i valori dall'ultima chiusura
BEGIN

	INSERT INTO @RisStatus
	(
		DenoID,
		Acronim,
		Amount
	)
/*



DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '3.18.2020'
set 	@oggi = 'OGGI'
select * from  [ForIncasso].[fn_GetChipsRipristinati] (@gaming,6)
order by DenoID
--*/	
--*/
	SELECT 
	[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,
	[ForIncasso].[fn_AcronimEx](ValueTypeID)		AS Acronim,
	SUM(Chiusura) + SUM(Ripristino)					AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati]  (@gaming,6)  --RISERVA
	WHERE DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)

END
ELSE
BEGIN
	--è ancora aperto: prendi i valori dallo stato corrente
	INSERT INTO @RisStatus
	(
		DenoID,
		Acronim,
		Amount
	)
/*



DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '4.18.2020'
set 	@oggi = 'OGGI'
select * from  [ForIncasso].[fn_GetChipsRipristinati] (@gaming,6)
order by DenoID
--*/		
	SELECT 	
	[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,
	[ForIncasso].[fn_AcronimEx](ValueTypeID)		AS Acronim,
	Stato											AS Amount
	FROM [Accounting].[fn_GetRiservaChipStatus] ()
	WHERE  DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky

END





/****************************	
*							*
*	Casse,CC,MS e Riserva	*
*							*
*****************************/
--insert casse,CC,MS e Riserva
INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
/*




DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '2.10.2020'
set 	@oggi = 'OGGI'

--*/
SELECT 	'CHIPMOV_' + cass.Acronim + '_' + @oggi + '_CAS_' + cast (cass.DenoID AS VARCHAR(16) ) AS ForIncassoTag,
	(cass.Apertura + CC.Apertura + ms.Amount + ris.Amount) AS Amount
--SELECT a.*,b.*,c.*,d.*
FROM 
(	
/*


DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '2.10.2020'
set 	@oggi = 'OGGI'

--*/	

	SELECT [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,4)  --CASSE
	WHERE ValueTypeID <> 36  AND DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),Acronim
) cass
FULL OUTER JOIN 
(
	SELECT [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,7)  --CC
	WHERE ValueTypeID <> 36  AND DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),Acronim

) CC ON CC.DenoID = cass.DenoID AND cass.Acronim = CC.Acronim
FULL OUTER JOIN @RisStatus ris ON ris.DenoID = cass.DenoID AND ris.Acronim = cass.Acronim
FULL OUTER JOIN @MSStatus ms ON ms.DenoID = cass.DenoID AND ms.Acronim = cass.Acronim 
where ms.Acronim <> 'CHFE'




--inserisci il conteggio MS dei chips chf gioco euro

INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
SELECT 
'CHIPMOV_CHFE_' + @oggi + '_MS_' + CAST(ms.DenoID AS VARCHAR(3)) AS ForIncassoTag,
ms.Amount + ris.Amount	
FROM @MSStatus ms
FULL OUTER JOIN @RisStatus ris ON ris.DenoID = ms.DenoID AND ris.Acronim = ms.Acronim
WHERE ms.Acronim = 'CHFE'

--insert anche dotazione nel report

INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)

/*


DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '4.6.2020'
set 	@oggi = 'OGGI'

--*/	
SELECT 
'CHIPMOV_' + a.Acronim + '_' + @oggi + '_DOT_' + cast (a.Deno AS VARCHAR(16) ) AS ForIncassoTag,
a.Amount	
FROM
(

/*
	SELECT  
		[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS Deno,
		[ForIncasso].[fn_AcronimEx](ValueTypeID) AS Acronim,
		SUM(Quantity)			AS Amount
	FROM [Accounting].[vw_AllConteggiDenominations]
	WHERE [SnapshotTypeID] = 17 --Conteggio dotazione gettoni
	AND GamingDate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
	AND DenoID NOT IN (@luckyDenoID,10,95,96,97)  --forget about lucky chip and 500 chf and medaglie

	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)
*/



	SELECT  
		[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS Deno,
		[ForIncasso].[fn_AcronimEx](ValueTypeID) AS Acronim,
		SUM((Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END)	)		AS Amount
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
	AND SourceGamingDate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
	AND DenoID NOT IN (@luckyDenoID,10,95,96,97)  --forget about lucky chip and 500 chf and medaglie

	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)
) a
RETURN

END
GO