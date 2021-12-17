SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE FUNCTION [Accounting].[fn_GetTableChipStatus]
(
    @lifecycleid INT
)
/*

select * from [Accounting].[fn_GetTableChipStatus] (185467)

*/
RETURNS @ChipsStatus TABLE (
	stockID				INT,
	StockTypeID			INT,
	LifeCycleID			INT, 
	denomination		FLOAT,
	denoid				INT, 
	FDescription		VARCHAR(64),
	valuetypeid			INT, 
	[CurrencyAcronim]	NVARCHAR(3),
	Apertura				INT,
	FillsToMe				INT,
	CreditsToMe			INT,
	CambioRicToMe			INT,
	CambioConToMe			INT,
	FillsFromMe			INT,
	CreditsFromMe			INT,
	CambioRicFromMe		INT,
	CambioConFromMe		INT,
	Stato				INT
	)
--WITH SCHEMABINDING
AS
BEGIN

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('4.4.2019' ,'OGGI')
 execute [ForIncasso].[usp_ChipMovement] '5.3.2019' ,'IERI'
 

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '5.30.2019'
set 	@oggi = 'OGGI'


--*/



INSERT INTO @ChipsStatus
(
	stockID					,
	StockTypeID				,
	LifeCycleID				,
	denomination			,
	denoid					,
	FDescription			,
	valuetypeid				,
	[CurrencyAcronim]		,
	Apertura			,
	FillsToMe			,
	CreditsToMe		,
	CambioRicToMe		,
	CambioConToMe		,
	FillsFromMe		,
	CreditsFromMe		,
	CambioRicFromMe	,
	CambioConFromMe	,
	Stato				
)
SELECT
	s.StockID,
	s.StockTypeID,
	@lifecycleid	,
	d.Denomination,
	d.DenoID,
	d.FDescription,
	d.ValueTypeID,
	d.[CurrencyAcronim] ,
	( ISNULL(ap.Quantity,0)				) AS Apertura			,
	( ISNULL(fillsToMe.Total,0) 		) AS FillsToMe			,
	( ISNULL(creditToMe.Total,0) 		) AS CreditsToMe		,
	( ISNULL(cambioRicToMe.Total,0)		) AS CambioRicToMe		,
	( ISNULL(cambioConToMe.Total,0)		) AS CambioConToMe		,
	( ISNULL(fillsFromMe.Total,0) 		) AS FillsFromMe		,
	( ISNULL(creditFromMe.Total,0) 		) AS CreditsFromMe		,
	( ISNULL(cambioRicFromMe.Total,0)	) AS CambioRicFromMe	,
	( ISNULL(cambioConFromMe.Total,0)	) AS CambioConFromMe	,
	ISNULL(ap.Quantity,0) -- Apertura,
	
	--gettoni dati da me ad altri
	- ISNULL(fillsToMe.Total,0) 
	- ISNULL(cambioRicToMe.Total,0) 
	- ISNULL(creditFromMe.Total,0)  
	- ISNULL(cambioConFromMe.Total,0)
	 
	--gettoni versati a me da altri
	+ ISNULL(creditToMe.Total,0) 
	+ ISNULL(cambioConToMe.Total,0) 
	+ ISNULL(fillsFromMe.Total,0) 
	+ ISNULL(cambioRicFromMe.Total,0) 

	AS Stato
--let's start from the active stocks
FROM Accounting.vw_AllStockLifeCycles s 
INNER JOIN CasinoLayout.StockComposition_Denominations sc	ON sc.StockCompositionID = s.StockCompositionID
INNER JOIN CasinoLayout.vw_AllDenominations				d	ON d.DenoID = sc.DenoID

--situazione al conteggio entrata
LEFT OUTER JOIN [Accounting].[vw_AllSnapshotDenominations] ap ON ap.LifeCycleID = s.LifeCycleID 
		AND AP.SnapshotTypeID = 5
		AND sc.DenoID = ap.DenoID 
	
--THEN FILL VALUES
--fills for which I am the destination
LEFT OUTER JOIN 
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --fill
	GROUP BY DestLifeCycleID,denoid
)fillsToMe 
ON	fillsToMe.DestLifeCycleID	= s.LifeCycleID 
AND fillsToMe.denoid			= sc.DenoID

--fills for which I am the source
LEFT OUTER JOIN 
(
	SELECT SourceLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --fill
	AND DestLifeCycleID IS NOT null
	GROUP BY SourceLifeCycleID,denoid
)fillsFromMe 
ON	fillsFromMe.SourceLifeCycleID	= s.LifeCycleID 
AND fillsFromMe.denoid				= sc.DenoID

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
	SELECT SourceLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 4 --credit
	AND DestLifeCycleID IS NOT null
	GROUP BY SourceLifeCycleID,denoid
)creditFromMe
ON	creditFromMe.SourceLifeCycleID	= s.LifeCycleID 
AND creditFromMe.denoid				= sc.DenoID

--THEN CAMBIO VALUES in richiesta
--cambio for which I am the destination
LEFT OUTER JOIN 
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 2 --cambio
	AND CashInbound = 1
	GROUP BY DestLifeCycleID,denoid
) cambioRicToMe 
ON	cambioRicToMe.DestLifeCycleID	= s.LifeCycleID 
AND cambioRicToMe.denoid			= sc.DenoID

--cambio for which I am the source
LEFT OUTER JOIN 
(
	SELECT SourceLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 2 --cambio
	AND CashInbound = 1
	AND DestLifeCycleID IS NOT null
	GROUP BY SourceLifeCycleID,denoid
) cambioRicFromMe 
ON	cambioRicFromMe.SourceLifeCycleID	= s.LifeCycleID 
AND cambioRicFromMe.denoid				= sc.DenoID

--THEN CAMBIO VALUES in consegna
--cambio for which I am the destination
LEFT OUTER JOIN 
(
	SELECT DestLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 2 --cambio
	AND CashInbound = 0
	GROUP BY DestLifeCycleID,denoid
) cambioConToMe 
ON	cambioConToMe.DestLifeCycleID = s.LifeCycleID 
AND	cambioConToMe.denoid = sc.DenoID

--cambio for which I am the source
LEFT OUTER JOIN 
(
	SELECT SourceLifeCycleID,DenoID,
	SUM(Quantity) AS Total 
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 2 --cambio
	AND CashInbound = 0
	AND DestLifeCycleID IS NOT null
	GROUP BY SourceLifeCycleID,denoid
) cambioConFromMe 
ON	cambioConFromMe.SourceLifeCycleID	= s.LifeCycleID 
AND cambioConFromMe.denoid				= sc.DenoID


WHERE sc.IsRiserva = 0 
AND d.ValueTypeID IN(1,36,42,59) --solo i gettoni sfr, gettoni gioco ed euro e poker
AND	s.StockTypeID IN (1,2,3,4,5,6,7) --tavoli,smt,trolleys,cc,ms,riserva,e incasso
AND d.Denomination NOT IN (0,500)--forget about lucy chip and 500 chf 
and d.DenoID not in (95,96,97)  --forget about medaglie
AND s.LifeCycleID = @lifecycleID

RETURN
END


GO
