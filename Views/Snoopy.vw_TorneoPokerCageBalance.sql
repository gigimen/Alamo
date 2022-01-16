SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[vw_TorneoPokerCageBalance]
AS
SELECT 
ISNULL(ci.Movimenti		,0) AS MovCashIN								  ,
ISNULL(co.Movimenti		,0) AS MovCashOUT								  ,
cast(ISNULL(ci.AmountCents	,0) as float) / 100.0 AS AmountCashIN								  ,
cast(ISNULL(co.AmountCents	,0) as float) / 100.0 AS AmountCashOUT								  ,
ISNULL(ci.Tag				,co.Tag				) AS Tag				  ,
ISNULL(ci.LifeCycleID		,co.LifeCycleID		) AS LifeCycleID		  ,
ISNULL(ci.GamingDate		,co.GamingDate		) AS GamingDate		

FROM 
(
	SELECT COUNT([PK_MovID]) AS Movimenti
		,SUM([TaxCents] + [BuyInCents]) AS AmountCents
      ,[Tag]
      ,[LifeCycleID]
      ,[PagamentoGamingDate] AS GamingDate
  FROM [Snoopy].[vw_TorneoPokerCashMov]
  WHERE [MoveType] = 0
  GROUP BY 
	[Tag]
       ,[LifeCycleID]
     ,[PagamentoGamingDate]
) ci
FULL OUTER join
(
	SELECT COUNT([PK_MovID]) AS Movimenti
		,SUM(AmountCents) AS AmountCents
      ,[Tag]
      ,[StockID]
      ,[StockTypeID]
      ,[LifeCycleID]
      ,[PagamentoGamingDate] AS GamingDate
  FROM [Snoopy].[vw_TorneoPokerCashMov]
  WHERE [MoveType] <> 0
  GROUP BY CASE WHEN  [MoveType] = 0 THEN 1 ELSE 0 END 
      ,[Tag]
      ,[StockID]
      ,[StockTypeID]
      ,[LifeCycleID]
      ,[PagamentoGamingDate]
) co ON ci.[LifeCycleID] =co.[LifeCycleID]

GO
