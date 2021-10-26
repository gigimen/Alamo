SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [ForIncasso].[fn_ControlBSELiveGame] 
(
@from			DATETIME,
@to				DATETIME
)

RETURNS   @ControlBSELiveGame TABLE(
	[Tag]					VARCHAR(16),
	[StockID]				INT,
	[LifeCycleID]			INT,
	[GamingDate]			DATETIME,
	[DropStimato]			INT,
	[DropStimatoCHF]		FLOAT,
	[CashBox]				INT,
	[BSE (CHF)]				FLOAT,
	[RisultatoStimato]		FLOAT,
	[PercEuroBox]			FLOAT,
	[euroRate]				FLOAT
	)
AS
BEGIN

/*

declare @from			DATETIME,@to				DATETIME

set @from	= '8.15.2019'
set @to		= '8.20.2019'

--*/
INSERT INTO @ControlBSELiveGame
(
    Tag,
    StockID,
    LifeCycleID,
    GamingDate,
    [DropStimato],
    [DropStimatoCHF],
    CashBox,
    [BSE (CHF)],
    RisultatoStimato,
	[PercEuroBox]			,
	[euroRate]				
)
SELECT	s.Tag,
		s.[StockID]				,
		a.[LifeCycleID]			,
		a.[GamingDate]			,
		a.[DropStimato]			,
		a.DropStimato * ((1-PercEuroBox) + PercEuroBox * Eurorate) AS DropStimatoCHF,
		a.CashBox,
		a.BSE,
		estResult.BSE												AS [RisultatoStimato],
		a.percEuroBox			,
		a.[euroRate]				
FROM 
(
	SELECT 	
		b.[StockID]				,
		b.[LifeCycleID]			,
		b.[GamingDate]			,
		b.Eurorate,
		MAX(b.[EstimatedDrop])	AS [DropStimato]		,
		[Accounting].[fn_PerEuroBox]  (b.[GamingDate],b.[StockID]) AS percEuroBox,
		SUM(CASE WHEN CurrencyID = 0 THEN b.[totConteggio] * Eurorate	ELSE b.[totConteggio] END ) AS CashBox,
		SUM(CASE WHEN CurrencyID = 0 THEN b.[BSE]	* Eurorate	ELSE b.[BSE] END ) AS BSE
	FROM [ForIncasso].[fn_GetBSELiveGame] (@from  ,@to) b
	GROUP BY 
		b.[StockID]				,
		b.[LifeCycleID]			,
		b.Eurorate,
		b.[GamingDate]			
) a
INNER JOIN CasinoLayout.Stocks s ON s.StockID = a.StockID
LEFT OUTER	JOIN [Accounting].[vw_BSELiveGameEstimatedResults] estResult ON estResult.LifeCycleID = a.LifeCycleID 


RETURN

END

GO
