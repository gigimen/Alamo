SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_ControlloMS]
AS

/*

questa query controlla (nel campo controllo)

che la chiusra del MS sia data dalla formula

Apertura + Consegantrolley +consegnaTavoli -RiprstinoTavoli - ripristinoTrolley + Conteggio 

di tutti i gettoni



select * from [Accounting].[vw_ControlloMS] a
WHERE a.GamingDate >='6.1.2019'  
ORDER BY a.GamingDate,a.CurrencyAcronim


*/
SELECT 
		Tavoli
		,Casse
		,GamingDate
		,CurrencyAcronim
		,[TavChiusura]	
		,[TavConsegna]  
		,[TavRipristino]
		,[TavApertura]
		,[CasChiusura]	
		,[CasConsegna]  
		,[CasRipristino]
		,[CasApertura]
		,[ApMainStock]			
		,[ChMainStock]	
		,[Conteggio]	
		,MovimentoDotazione
		,a.ApRiserva
		,a.ChRiserva
		,a.ApMainStock - [ChMainStock]		-- variazione al Mainstock
		+ a.TavConsegna - a.TavRipristino	-- movimento verso i tavoli
		+ a.CasConsegna - a.CasRipristino	-- movimento verso le casse 
		+ a.Conteggio 						-- totale dai conteggi
		+ a.ApRiserva - a.ChRiserva			-- variazione nella riserva
		+ MovimentoDotazione				-- movimento della dotazione gettoni (eliminati o comprati nuovi)
		AS Controllo
FROM
(
	SELECT 
	--st.FDescription AS StockType,a.[StockTypeID],
			(tav.StockCount) AS Tavoli,
			(cas.StockCount) AS Casse,
			tav.GamingDate,
			tav.CurrencyAcronim
			  ,(tav.[Chiusura]	)	AS [TavChiusura]	
			  ,(tav.[Consegna]	)	AS [TavConsegna]  
			  ,(tav.[Ripristino])	AS [TavRipristino]
			  ,(tav.[apertura]	)	AS [TavApertura]
			  ,(cas.[Chiusura]	)	AS [CasChiusura]	
			  ,(cas.[Consegna]	)	AS [CasConsegna]  
			  ,(cas.[Ripristino])	AS [CasRipristino]
			  ,(cas.[apertura]	)	AS [CasApertura]
			  ,apMS.Apertura		AS [ApMainStock]	
			  ,chMS.Chiusura		AS [ChMainStock]	
			  ,ISNULL(CASE WHEN tav.CurrencyAcronim = 'EUR' THEN ris.ApRiservaEUR ELSE ris.ApRiservaCHF END,0) AS [ApRiserva]	
			  ,ISNULL(CASE WHEN tav.CurrencyAcronim = 'EUR' THEN ris.ChRiservaEUR ELSE ris.ChRiservaCHF END,0) AS [ChRiserva]	
			  ,ISNULL(cont.totConteggio,0)	AS Conteggio	
			  ,ISNULL(dot.TotaleGettoni,0)  AS MovimentoDotazione
	FROM 
	(
		SELECT 
			  COUNT(DISTINCT [StockID]) AS StockCount
			  ,[GamingDate]
			  ,[CurrencyAcronim]
			  ,SUM([Chiusura]	* Denomination)	AS [Chiusura]	
			  ,SUM([Consegna]	* Denomination)	AS [Consegna]  
			  ,SUM([Ripristino]	* Denomination)	AS [Ripristino]
			  ,SUM([Chiusura]	* Denomination) - SUM([Consegna]  * Denomination) + SUM([Ripristino]* Denomination) AS Apertura
		  FROM [Accounting].[vw_AllChiusuraConsegnaDenominations] a
			INNER JOIN CasinoLayout.StockTypes st ON st.StockTypeID = a.StockTypeID	  
			WHERE ValueTypeID IN (1,42,36) AND a.StockTypeID IN (1,3)
		  GROUP BY     
				[GamingDate]
			  ,[CurrencyAcronim]
	) tav
	FULL OUTER JOIN
	(
		SELECT 
			  COUNT(DISTINCT [StockID]) AS StockCount
			  ,[GamingDate]
			  ,[CurrencyAcronim]
			  ,SUM([Chiusura]	* Denomination)	AS [Chiusura]	
			  ,SUM([Consegna]	* Denomination)	AS [Consegna]  
			  ,SUM([Ripristino]	* Denomination)	AS [Ripristino]
			  ,SUM([Chiusura]	* Denomination) - SUM([Consegna]  * Denomination) + SUM([Ripristino]* Denomination) AS Apertura
		  FROM [Accounting].[vw_AllChiusuraConsegnaDenominations] a
			INNER JOIN CasinoLayout.StockTypes st ON st.StockTypeID = a.StockTypeID	  
			WHERE ValueTypeID IN (1,42,36) AND a.StockTypeID IN (4,7)
		  GROUP BY     
				[GamingDate]
			  ,[CurrencyAcronim]
	) cas ON cas.GamingDate = tav.GamingDate AND cas.CurrencyAcronim = tav.CurrencyAcronim
	FULL OUTER JOIN
	(
		SELECT 
			  [GamingDate]
			  ,[CurrencyAcronim]
			  ,SUM(Denomination * Quantity) AS Apertura
		FROM Accounting.vw_AllSnapshotDenominations
		WHERE ValueTypeID IN (1,42,36) AND StockID = 31 AND SnapshotTypeID = 5	--Conteggio Entrata
		GROUP BY [GamingDate]
			  ,[CurrencyAcronim]
	) apMS ON apMS.GamingDate = tav.GamingDate AND apMS.CurrencyAcronim = tav.CurrencyAcronim
	FULL OUTER JOIN
	(
		SELECT 
			  [GamingDate]
			  ,[CurrencyAcronim]
			  ,SUM(Denomination * Quantity) AS Chiusura
		FROM Accounting.vw_AllSnapshotDenominations
		WHERE ValueTypeID IN (1,42,36) AND StockID = 31 AND SnapshotTypeID = 3	--Chiusura
		GROUP BY [GamingDate]
			  ,[CurrencyAcronim]
	) chMS ON chMS.GamingDate = tav.GamingDate AND chMS.CurrencyAcronim = tav.CurrencyAcronim
	FULL OUTER JOIN
	(
		SELECT 
			  [GamingDate]
			  ,[CurrencyAcronim]
			  ,SUM([Quantity]	* Denomination)	AS [totConteggio]
		  FROM [Accounting].[vw_AllConteggiDenominations] a
		WHERE ValueTypeID IN (1,42,36) --AND a.StockID IN (47) 
		AND a.SnapshotTypeID IN(
				7	,--Conteggio Box tavoli
				8	,--Conteggio Tronc Tavoli
				9	,--Conteggio Tronc
				10	)--Conteggio Gastro

		  GROUP BY     
				[GamingDate]
			  ,[CurrencyAcronim]
	) cont ON cont.GamingDate = tav.GamingDate AND cont.CurrencyAcronim = tav.CurrencyAcronim
	FULL OUTER JOIN [Accounting].[vw_MovimentiDotazioneByCurrency] dot ON dot.GamingDate = tav.GamingDate AND dot.CurrencyAcronim = tav.CurrencyAcronim
	FULL OUTER JOIN
	(
		select 
			ch.GamingDate,
			ch.LifeCycleID,
			Accounting.fn_GetPrevLifeCycleID(ch.GamingDate,ch.StockID) AS prevLFID,
			ch.TotalCHF AS ChRiservaCHF,
			ch.TotalEUR AS ChRiservaEUR,
			ap.TotalCHF AS ApRiservaCHF,
			ap.TotalEUR AS ApRiservaEUR
		from Accounting.vw_AllSnapshotsEx ch
		LEFT OUTER JOIN Accounting.vw_AllSnapshotsEx ap ON ap.LifeCycleID = Accounting.fn_GetPrevLifeCycleID(ch.GamingDate,ch.StockID) AND ap.SnapshotTypeID = 3 --Chiusura
		WHERE  ch.StockID = 32 and ch.SnapshotTypeID = 3 --Chiusura	
	) ris ON ris.GamingDate = tav.GamingDate  
	
) a
WHERE a.ChMainStock IS NOT null
GO
