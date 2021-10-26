SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Marketing].[vw_StatisticheMensiliBuoniCena] 
AS
SELECT 
	ISNULL(mdslot.giorni			,ISNULL(mdlg.giorni				,ISNULL(lg.giorni			,ISNULL(slot.giorni			,lclg.giorni			)))) AS giorni	,
	ISNULL(mdslot.anno				,ISNULL(mdlg.anno				,ISNULL(lg.anno				,ISNULL(slot.anno			,lclg.anno				)))) AS anno	,
	ISNULL(mdslot.mese				,ISNULL(mdlg.mese				,ISNULL(lg.mese				,ISNULL(slot.mese			,lclg.mese				)))) AS mese	,
	ISNULL(mdslot.nmese				,ISNULL(mdlg.nmese				,ISNULL(lg.nmese			,ISNULL(slot.nmese			,lclg.nmese				)))) AS nmese	,
	ISNULL(mdslot.OffertaPremioID	,ISNULL(mdlg.OffertaPremioID	,ISNULL(lg.OffertaPremioID	,ISNULL(slot.OffertaPremioID,lclg.OffertaPremioID	)))) AS OffertaPremioID	,
	ISNULL(mdslot.[Premio]			,ISNULL(mdlg.[Premio]			,ISNULL(lg.[Premio]			,ISNULL(slot.[Premio]		,lclg.Premio			)))) AS [Premio]	,
	ISNULL(ISNULL(slot.quanti		,ISNULL(mdslot.quanti,0)			),0)	AS SlotQuanti,
	ISNULL(ISNULL(lg.quanti			,ISNULL(mdlg.quanti,lclg.quanti)),0)	AS LGQuanti
FROM
(
	SELECT 
		COUNT(*)							AS quanti,
		COUNT(DISTINCT OrdineGamingDate)	AS giorni,
		OffertaPremioID,
		[Premio],
		DATEPART(YEAR,OrdineGamingDate)		AS anno,
		DATEPART(MONTH,OrdineGamingDate)	AS mese,
		DATENAME(MONTH,OrdineGamingDate)	AS nmese
	FROM [Marketing].[vw_AllAssegnazionePremi] 
	WHERE PromotionID = 19 AND [AssigningSectorID] = 2 
	GROUP BY [Premio],
	OffertaPremioID,
	DATEPART(YEAR,OrdineGamingDate),
	DATEPART(MONTH,OrdineGamingDate),
	DATENAME(MONTH,OrdineGamingDate)
) slot
FULL OUTER JOIN 
(
	SELECT 
		COUNT(*)							AS quanti,
		COUNT(DISTINCT OrdineGamingDate)	AS giorni,
		OffertaPremioID,
		[Premio],
		DATEPART(YEAR,OrdineGamingDate)		AS anno,
		DATEPART(MONTH,OrdineGamingDate)	AS mese,
		DATENAME(MONTH,OrdineGamingDate)	AS nmese
	FROM [Marketing].[vw_AllAssegnazionePremi] 
	WHERE PromotionID = 19 AND [AssigningSectorID] = 3 
	GROUP BY [Premio],
	OffertaPremioID,
	DATEPART(YEAR,OrdineGamingDate),
	DATEPART(MONTH,OrdineGamingDate),
	DATENAME(MONTH,OrdineGamingDate)
) lg ON lg.OffertaPremioID = slot.OffertaPremioID 
AND	lg.[Premio] = slot.[Premio]
AND lg.anno	 = slot.anno	 
AND	lg.mese	 = slot.mese	 
AND	lg.nmese = slot.nmese 
FULL OUTER JOIN 
(
	SELECT 
		COUNT(*)							AS quanti,
		COUNT(DISTINCT OrdineGamingDate)	AS giorni,
		OffertaPremioID,
		[Premio],
		DATEPART(YEAR,OrdineGamingDate)		AS anno,
		DATEPART(MONTH,OrdineGamingDate)	AS mese,
		DATENAME(MONTH,OrdineGamingDate)	AS nmese
	FROM [Marketing].[vw_AllAssegnazionePremi] 
	WHERE PromotionID = 26 AND [SectorID] = 3 
	GROUP BY [Premio],
	OffertaPremioID,
	DATEPART(YEAR,OrdineGamingDate),
	DATEPART(MONTH,OrdineGamingDate),
	DATENAME(MONTH,OrdineGamingDate)
) mdlg ON mdlg.OffertaPremioID = slot.OffertaPremioID 
AND	mdlg.[Premio] = slot.[Premio]
AND mdlg.anno	 = slot.anno	 
AND	mdlg.mese	 = slot.mese	 
AND	mdlg.nmese = slot.nmese 
FULL OUTER JOIN 
(
	SELECT 
		COUNT(*)							AS quanti,
		COUNT(DISTINCT OrdineGamingDate)	AS giorni,
		OffertaPremioID,
		[Premio],
		DATEPART(YEAR,OrdineGamingDate)		AS anno,
		DATEPART(MONTH,OrdineGamingDate)	AS mese,
		DATENAME(MONTH,OrdineGamingDate)	AS nmese
	FROM [Marketing].[vw_AllAssegnazionePremi] 
	WHERE PromotionID = 26 AND [SectorID] IN(5, 2) 
	GROUP BY [Premio],
	OffertaPremioID,
	DATEPART(YEAR,OrdineGamingDate),
	DATEPART(MONTH,OrdineGamingDate),
	DATENAME(MONTH,OrdineGamingDate)
)	mdslot ON mdslot.OffertaPremioID = mdlg.OffertaPremioID 
AND	mdslot.[Premio] = mdlg.[Premio]
and mdslot.anno	 = mdlg.anno	 
and	mdslot.mese	 = mdlg.mese	 
and	mdslot.nmese = mdlg.nmese

/*lucky chips*/
FULL OUTER JOIN 
(
	SELECT 
		COUNT(*)							AS quanti,
		COUNT(DISTINCT OrdineGamingDate)	AS giorni,
		OffertaPremioID,
		[Premio],
		DATEPART(YEAR,OrdineGamingDate)		AS anno,
		DATEPART(MONTH,OrdineGamingDate)	AS mese,
		DATENAME(MONTH,OrdineGamingDate)	AS nmese
	FROM [Marketing].[vw_AllAssegnazionePremi] 
	WHERE PromotionID = 27 AND [SectorID] = 3 
	GROUP BY [Premio],
	OffertaPremioID,
	DATEPART(YEAR,OrdineGamingDate),
	DATEPART(MONTH,OrdineGamingDate),
	DATENAME(MONTH,OrdineGamingDate)
) lclg ON lclg.OffertaPremioID = slot.OffertaPremioID 
AND	lclg.[Premio] = slot.[Premio]
AND lclg.anno	 = slot.anno	 
AND	lclg.mese	 = slot.mese	 
AND	lclg.nmese = slot.nmese 

GO
