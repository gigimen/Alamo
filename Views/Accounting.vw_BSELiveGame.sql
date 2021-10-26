SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_BSELiveGame]
WITH SCHEMABINDING
AS

SELECT [Contato]
      ,[Tag]
      ,[StockID]
      ,[GamingDate]
      ,[PrevChiusura]
      ,[Ripristino]
      ,[Fills]
      ,[Credits]
      ,[EstimatedDrop]
      ,[totConteggio]
      ,[FormerLifCycle]
      ,[CurrentLifCycle]
      ,[Apertura]
      ,[Chiusura]
      ,[NelFloat]
      ,[Consegna]
	  ,				Chiusura		
				+ totConteggio
				- apertura
				- Fills
				+ Credits AS BSE
	  ,EstimatedBSE
      ,[Tronc]
FROM
(

	SELECT	CASE WHEN cont.StockID IS NULL THEN 0 ELSE 1 END AS Contato,
			ISNULL(s.Tag,cont.Tag)							AS Tag,
			ISNULL(s.StockID,cont.StockID)					AS StockID,
			ISNULL(s.GamingDate,cont.GamingDate)			AS GamingDate,									
			ISNULL((ch.[TotalCHF]),0)						AS PrevChiusura,
			ISNULL((myrip.TotalForDest),0)					AS Ripristino,
			ISNULL((fil.Total),0)							AS Fills,
			ISNULL((cre.Total),0)							AS Credits,
			ISNULL((exDrop.Quantity * exdrop.Denomination * exdrop.ExchangeRate),0)		AS EstimatedDrop,
			ISNULL((cont.[TotSfr]),0)						AS totConteggio,
			CASE WHEN prevch.GamingDate < '3.23.2017' THEN 'Bef big change' ELSE 'Nuova era' END AS FormerLifCycle,
			CASE WHEN ch.GamingDate < '3.23.2017' THEN 'Bef big change' ELSE 'Nuova era' END AS CurrentLifCycle,
			CASE 
				WHEN prevch.GamingDate < '3.23.2017' THEN --beforebig change
					ISNULL((prevch.[TotalCHF]),0) 
					- ISNULL((prevcon.TotalForSource),0) 
					+ ISNULL((myrip.TotalForDest),0) 		
				ELSE
					ISNULL((prevch.[TotalCHF]),0)  
					+ ISNULL((myrip.TotalForDest),0)
			END												AS Apertura,
			CASE WHEN ch.GamingDate < '3.23.2017' THEN
				ISNULL((ch.TotalCHF),0) --beforebig change		
			ELSE
				ISNULL(ch.TotalCHF,0) + ISNULL(CON.TotalForSource,0)		
			END												AS Chiusura,
			CASE WHEN ch.GamingDate < '3.23.2017' THEN --beforebig change
					ISNULL((ch.TotalCHF),0) 
					- ISNULL((con.TotalForSource),0) 
				ELSE
					ISNULL((ch.TotalCHF),0)
			END												AS NelFloat,
			ISNULL((con.TotalForSource),0)					AS Consegna,
			ISNULL(tronc.TotSfr,0)							AS Tronc,
			estResult.[BSE]									AS EstimatedBSE
	FROM [Accounting].[vw_AllChiusuraConsegnaRipristino] s  
	FULL OUTER JOIN [Accounting].[vw_TableCashContato] cont ON cont.StockID = s.StockID AND cont.GamingDate = s.GamingDate
	--look for my ripristino
	LEFT OUTER JOIN Accounting.vw_AllTransactions myRIP ON myRIP.DestLifeCycleID = s.LifeCycleID AND myRIP.OpTypeID = 5 --only ripristino operations
	--look for Consegna that generate my ripristino
	LEFT OUTER JOIN Accounting.vw_AllTransactions prevCON ON prevCON.SourceStockID = myRIP.DestStockID AND prevCON.SourceGamingDate = myRip.SourceGamingDate AND prevCON.OpTypeID = 6 --only Consegna operations
	--look for the Chiusura that generated the Consegna
	LEFT OUTER	JOIN [Accounting].[vw_AllSnapshots] prevch ON prevCON.SourceLifeCycleID = prevch.LifeCycleID AND prevch.SnapshotTypeID = 3 --Chiusura
	FULL OUTER JOIN [Accounting].[vw_TableTroncContato] tronc ON tronc.StockID = s.StockID AND tronc.GamingDate = s.GamingDate
	FULL OUTER JOIN [Accounting].[vw_TableLuckyChipsContato] luc ON luc.StockID = s.StockID AND luc.GamingDate = s.GamingDate
	LEFT OUTER	JOIN [Accounting].[vw_AllTransactions] con ON con.TransactionID = s.CONTransactionID
	LEFT OUTER	JOIN [Accounting].[vw_AllSnapshots] ch ON ch.LifeCycleSnapshotID = s.ChiusuraSnapshotID
	LEFT OUTER	JOIN 
	(
		SELECT SourceLifeCycleID AS LifeCycleID,
		SUM(TotalForSource) AS Total 
		FROM [Accounting].[vw_AllTransactions] 
		WHERE OpTypeID = 1 --fill
		GROUP BY SourceLifeCycleID
	) fil ON fil.LifeCycleID = s.LifeCycleID
	LEFT OUTER	JOIN  
	(
		SELECT SourceLifeCycleID AS LifeCycleID,
		SUM(TotalForSource) AS Total 
		FROM [Accounting].[vw_AllTransactions] 
		WHERE OpTypeID = 4 --credit
		GROUP BY SourceLifeCycleID
	)cre ON cre.LifeCycleID = s.LifeCycleID
	LEFT OUTER	JOIN [Accounting].[vw_AllSnapshotDenominations] exDrop ON exDrop.LifeCycleSnapshotID = s.ChiusuraSnapshotID AND exDrop.DenoID = 13
	LEFT OUTER	JOIN [Accounting].[vw_BSELiveGameEstimatedResults] estResult ON estResult.LifeCycleID = s.LifeCycleID 
	WHERE cont.StockID IS NOT NULL OR s.StockTypeID = 1 --and s.GamingDate = '4.21.2017'
) a
GO
