SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE FUNCTION [Accounting].[fn_GetMainStockChipStatus] ()
/*

select * from [Accounting].[fn_GetMainStockChipStatus] ()

*/
RETURNS @ChipsStatus TABLE (
	LifeCycleID			INT,
	GamingDate			DATETIME, 
	IsToday				BIT,
	Denomination		float,
	DenoID				INT, 
	ValueTypeID			INT, 
	[CurrencyAcronim]	NVARCHAR(3),
	Apertura			INT,
	ConsegnaSMT			INT,
	RipristinoSMT		INT,
	ConsegnaTrolleys	INT,
	RipristinoTrolleys	INT,
	PrelievoDaRiserva	INT,
	VersamentoInRiserva	INT,
	TotaleConteggio		INT,
	VersCassaCentrale	INT,
	Stato				INT
	)
AS
BEGIN


DECLARE    @LifeCycleID INT,@IsToday BIT,@GamingDate datetime

SELECT 
@LifeCycleID = LifeCycleID,
@GamingDate = GamingDate,
@IsToday = 
case 
when GamingDate = [GeneralPurpose].[fn_GetGamingLocalDate2] 
(
GETDATE(),0,2 --MS stock type
) then 1
else 0
end
FROM Accounting.tbl_LifeCycles 
WHERE StockID = 31 --MS
AND GamingDate = 
(
SELECT MAX(GamingDate) FROM Accounting.vw_AllStockLifeCycles WHERE StockID = 31
)

--SELECT @LifeCycleID AS 'LifeCycleID',@IsToday AS [ISTocday],@GamingDate AS '@GamingDate'


INSERT INTO @ChipsStatus
(
    LifeCycleID,
    GamingDate,
    IsToday,
    Denomination,
    DenoID,
    ValueTypeID,
    CurrencyAcronim,
    Apertura,
    ConsegnaSMT			,
    RipristinoSMT		,
    ConsegnaTrolleys,	
    RipristinoTrolleys	,
    PrelievoDaRiserva	,
    VersamentoInRiserva	,
	TotaleConteggio		,
	VersCassaCentrale,
    Stato
)
SELECT 
    @LifeCycleID,
    @GamingDate,
    @IsToday,
	d.Denomination,
	d.DenoID,
	d.ValueTypeID,
	d.[CurrencyAcronim] ,
	( ISNULL(ap.Quantity,0)				) AS Apertura			,
	( ISNULL(conSMT.Total,0) 			) AS ConsegnaSMT				,
	( ISNULL(ripSMT.Total,0) 			) AS RipristinoSMT			,
	( ISNULL(conTro.Total,0) 			) AS ConsegnaTrolleys		,
	( ISNULL(ripTro.Total,0) 			) AS RipristinoTrolleys		,
	( ISNULL(creditToMe.Total,0)		) AS PrelievoDaRiserva		,
	( ISNULL(fillsFromMe.Total,0)		) AS VersamentoInRiserva		,
	( ISNULL(cont.totConteggio,0)		) AS TotaleConteggio		,
	( ISNULL(vers.Amount,0)				) AS VersCassaCentrale		,
	ISNULL(ap.Quantity,0) -- Apertura,
	
	--gettoni dati da me ad altri
	- ISNULL(ripSMT.Total,0) 
	- ISNULL(ripTro.Total,0) 
	- ISNULL(fillsFromMe.Total,0)  
	 
	--gettoni versati a me da altri
	+ ISNULL(conSMT.Total,0) 
	+ ISNULL(conTro.Total,0) 
	+ ISNULL(creditToMe.Total,0)

	--gettoni nel conteggio
	+ ISNULL(cont.totConteggio,0)
	--gettoni versati a cassa centrale
	- ISNULL(vers.Amount,0)

	AS Stato
--let's start from the active stocks
FROM Accounting.vw_AllStockLifeCycles s 
INNER JOIN CasinoLayout.StockComposition_Denominations sc	ON sc.StockCompositionID = s.StockCompositionID
INNER JOIN CasinoLayout.vw_AllDenominations				d	ON d.DenoID = sc.DenoID

--situazione al conteggio entrata
LEFT OUTER JOIN [Accounting].[vw_AllSnapshotDenominations] ap ON ap.LifeCycleID = s.LifeCycleID 
		AND AP.SnapshotTypeID = 5
		AND sc.DenoID = ap.DenoID 
	
--THEN consegna da SMT VALUES
--consegna for which I am the destination
LEFT OUTER JOIN 
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 6 --consegna 
	AND SourceStockID = 30 --SMT
	GROUP BY DestLifeCycleID,denoid
)conSMT 
ON	conSMT.DestLifeCycleID	= s.LifeCycleID AND conSMT.denoid = sc.DenoID

--ripristini SMT for which I am the source
LEFT OUTER JOIN 
(
	SELECT SourceLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 5 --ripristini
	AND DestStockID = 30 --SMT
	GROUP BY SourceLifeCycleID,denoid
)ripSMT 
ON	ripSMT.SourceLifeCycleID	= s.LifeCycleID AND ripSMT.denoid = sc.DenoID
	
--THEN consegna dai trolleys
--consegna for which I am the destination
LEFT OUTER JOIN 
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 6 --consegna 
	AND SourceStockTypeID IN (4,7) --casse e CC
	GROUP BY DestLifeCycleID,denoid
)conTro 
ON	conTro.DestLifeCycleID	= s.LifeCycleID AND conTro.denoid = sc.DenoID

--ripristini trolleys for which I am the source
LEFT OUTER JOIN 
(
	SELECT SourceLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 5 --ripristini
	AND DestStockTypeID IN (4,7) --casse e CC
	GROUP BY SourceLifeCycleID,denoid
)ripTro 
ON	ripTro.SourceLifeCycleID	= s.LifeCycleID AND ripTro.denoid = sc.DenoID

--THEN CREDIT VALUES
--credits for which I am the destination
LEFT OUTER	JOIN  
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 4 --credit
	GROUP BY DestLifeCycleID,denoid
)creditToMe 
ON	creditToMe.DestLifeCycleID	= s.LifeCycleID 
AND creditToMe.denoid			= sc.DenoID


--credits for which I am the source
LEFT OUTER JOIN 
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --fill
	GROUP BY DestLifeCycleID,denoid
)fillsFromMe
ON	fillsFromMe.DestLifeCycleID		= s.LifeCycleID 
AND fillsFromMe.denoid				= sc.DenoID

--finally also conteggi

LEFT OUTER JOIN 
(
/*

declare @gamingdate datetime
set @gamingdate = '12.19.2021'

--*/		

		SELECT [DenoID]
			  ,SUM([Quantity])	AS [totConteggio]
		FROM [Accounting].[vw_AllConteggiDenominations] a
		WHERE [GamingDate] = @GamingDate and ValueTypeID IN (1,42,36,59) --AND a.StockID IN (47) 
		AND a.[SorvDoubleCheck] = 0

		  GROUP BY     
				[DenoID]
) cont on cont.DenoID = sc.DenoID
--se esiste già il versamento in cassa central bisogna detrarle dal MS
LEFT OUTER JOIN
 (
/*
DECLARE @gaming DATETIME,	@LifeCycleID int

SET		@gaming = '12.20.2021'

set @LifeCycleID = 196628
--*/	
	SELECT 
	DenoID,
	SUM([Quantity]) AS Amount
	from Accounting.vw_AllTransactionDenominations 
	WHERE ValueTypeID = 59--pokerchips
	AND SourceLifeCycleID = @LifeCycleID AND OpTypeID = 4 AND DestStockTypeID = 7
	--AND DestLifeCycleID IS NOT NULL --onlz if accepted bz cassa centra;e
	GROUP BY [DenoID]
) vers ON vers.DenoID = sc.DenoID
   
WHERE s.LifeCycleID = @LifeCycleID
AND d.ValueTypeID IN(1,36,42,59)


RETURN
END
GO
