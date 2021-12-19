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

select * from [ForIncasso].[fn_GetChipMovementPartialEx] ('11.27.2021','IERI',1)
select * from [ForIncasso].[fn_GetChipMovementPartialEx] ('11.28.2021','OGGI',1)

*/
RETURNS @RifList TABLE (ForIncassoTag VARCHAR(32) PRIMARY KEY CLUSTERED, Amount INT)
--WITH SCHEMABINDING
AS
BEGIN

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('4.4.2019' ,'OGGI',DEFAULT)
 execute [ForIncasso].[usp_ChipMovement] '5.3.2019' ,'IERI'
 
DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.21.2021'
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


/*


DECLARE @gaming DATETIME,	@oggi VARCHAR(16)


DECLARE @luckyDenoID INT

SET @luckyDenoID = 78

SET		@gaming = '11.28.2021'
set 	@oggi = 'OGGI'
--*/
DECLARE @MSStatus TABLE (DenoID INT, Acronim VARCHAR(4), Amount INT)
DECLARE @CloseSnapshotID int
--se MS è stato chiuso usa la funzione [ForIncasso].[fn_GetChipsRipristinati]
SELECT @CloseSnapshotID = [ForIncasso].[fn_IsMainStockOpen] (@gaming)
IF @CloseSnapshotID > 0 --E' chiuso o non è stato aperto: in questo caso prendi i valori dall'ultima chiusura
BEGIN

	INSERT INTO @MSStatus
	(
		DenoID,
		Acronim,
		Amount
	)
/*



DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.28.2021'
set 	@oggi = 'OGGI'

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

--SELECT * FROM @MSStatus

/************************************	
*									*
*	     RISERVA					*
*	temp table						*
* perché magari non è ancora chiusa *
*************************************/
/*




DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @CloseSnapshotID INT
DECLARE @luckyDenoID INT

SET @luckyDenoID = 78

SET		@gaming = '11.28.2021'
set 	@oggi = 'OGGI'
--*/
DECLARE @RisStatus TABLE (DenoID INT, Acronim VARCHAR(4), Amount INT)
--se MS è stato chiuso usa la funzione [ForIncasso].[fn_GetChipsRipristinati]
/*




DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @CloseSnapshotID INT

SET		@gaming = '11.22.2021'
set 	@oggi = 'OGGI'
--*/

SELECT @CloseSnapshotID = [ForIncasso].[fn_IsRiservaOpen] (@gaming)
--SELECT @CloseSnapshotID


IF @CloseSnapshotID > 0 --E' chiuso o non è stato aperto: in questo caso prendi i valori dall'ultima chiusura
BEGIN

	INSERT INTO @RisStatus
	(
		DenoID,
		Acronim,
		Amount
	)
/*




DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.21.2021'
set 	@oggi = 'OGGI'
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

DECLARE @luckyDenoID INT

SET		@luckyDenoID = 78
SET		@gaming = '11.21.2021'
SET 	@oggi = 'OGGI'

--*/		
	SELECT 	
	[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,
	[ForIncasso].[fn_AcronimEx](ValueTypeID)		AS Acronim,
	Stato											AS Amount
	FROM [Accounting].[fn_GetRiservaChipStatus] ()
	WHERE  DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky

END


--SELECT * FROM @RisStatus


/****************************	
*							*
*	Casse,CC,MS e Riserva	*
*							*
*****************************/
--insert casse,CC,MS e Riserva
INSERT INTO @RifList(ForIncassoTag,Amount)
/*


DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.21.2021'
set 	@oggi = 'OGGI'

--*/
SELECT 	'CHIPMOV_' + 
	ISNULL(cass.Acronim,ISNULL(CC.Acronim,ISNULL(ms.Acronim,ISNULL(ris.Acronim,vers.Acronim)))) + 
	'_' + @oggi + '_CAS_' + 
	CAST (ISNULL(cass.DenoID,ISNULL(CC.DenoID,ISNULL(ms.DenoID,ISNULL(ris.DenoID,vers.DenoID)))) AS VARCHAR(16) ) AS ForIncassoTag,
	(ISNULL(cass.Amount,0) + ISNULL(CC.Amount,0) + ISNULL(ms.Amount,0) + ISNULL(ris.Amount,0)+ ISNULL(vers.Amount,0)) AS Amount
	--,cass.*,CC.*,ms.*,ris.*,vers.*
FROM 
(	
/*
DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.22.2021'
set 	@oggi = 'OGGI'


--*/	

	SELECT [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,[ForIncasso].[fn_AcronimEx](ValueTypeID) AS Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Amount
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,4)  --CASSE
	WHERE ValueTypeID NOT IN(36) AND DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)
) cass
FULL OUTER JOIN 
(
/*
DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.28.2021'
set 	@oggi = 'OGGI'
select *,[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,7)

--*/		
	SELECT [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,[ForIncasso].[fn_AcronimEx](ValueTypeID) AS Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Amount
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,7)  --CC
	WHERE ValueTypeID NOT IN(36)  AND DenoID NOT IN (@luckyDenoID) --ignore chips gioco euro e lucky
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)

) CC ON CC.DenoID = cass.DenoID AND cass.Acronim = CC.Acronim
FULL OUTER JOIN  
(
	SELECT DenoID,Acronim,Amount
	FROM @RisStatus 
	WHERE Acronim <> 'CHFE' --ignora i gettoni gioco euro nella riserva
)ris ON ris.DenoID = CC.DenoID AND ris.Acronim = CC.Acronim
FULL OUTER JOIN 
(
	SELECT DenoID,Acronim,Amount
	FROM @MSStatus 
	WHERE Acronim <> 'CHFE' --ignora i gettoni gioco euro nel MS
)ms ON ms.DenoID = CC.DenoID AND ms.Acronim = CC.Acronim 
FULL OUTER JOIN 
--versamento gettoni poker da MS a CAssa centrale
(
/*
DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET		@gaming = '12.13.2021'
set 	@oggi = 'OGGI'


--*/	
	SELECT 
	[ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID) AS DenoID,
	[ForIncasso].[fn_AcronimEx](ValueTypeID)		AS Acronim,
	SUM([Quantity]) AS Amount
	from Accounting.vw_AllTransactionDenominations 
	WHERE ValueTypeID = 59--pokerchips
	AND SourceGamingDate = @gaming AND SourceStockID = 31 AND OpTypeID = 4
	AND DestLifeCycleID IS NOT NULL --onlz if accepted bz cassa centra;e
	GROUP BY [ForIncasso].[fn_DenoIndex](ValueTypeID,DenoID),[ForIncasso].[fn_AcronimEx](ValueTypeID)
) vers ON vers.DenoID = CC.DenoID AND vers.Acronim = CC.Acronim

ORDER BY ForIncassoTag



--inserisci il conteggio MS dei chips chf gioco euro

INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
SELECT 
'CHIPMOV_CHFE_' + @oggi + '_MS_' + CAST(ISNULL(ms.DenoID,ris.DenoID) AS VARCHAR(3)) AS ForIncassoTag,
ISNULL(ms.Amount,0) + ISNULL(ris.Amount,0)	
FROM 
(
	SELECT DenoID,Acronim,Amount
	FROM @RisStatus 
	WHERE Acronim = 'CHFE' --solo i gettoni gioco euro nella riserva
)ris 
FULL OUTER JOIN 
(
	SELECT DenoID,Acronim,Amount
	FROM @MSStatus 
	WHERE Acronim = 'CHFE' --solo i gettoni gioco euro nel MS
)ms ON ms.DenoID = ris.DenoID AND ms.Acronim = ris.Acronim 

--insert anche dotazione nel report

INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)

/*

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.21.2021'
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



/*
DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

DECLARE @luckyDenoID INT

SET @luckyDenoID = 78
SET		@gaming = '11.21.2021'
set 	@oggi = 'OGGI'

--*/	
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
