SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [Managers].[msp_EnterPlayerTracking]
@gaming datetime
AS

IF EXISTS( SELECT [GamingDate] FROM GoldenClub.tbl_PlayerTracking WHERE gamingdate = @gaming)
BEGIN
	PRINT 'clean up old values'
	DELETE FROM  GoldenClub.tbl_PlayerTracking WHERE gamingdate = @gaming
END

INSERT INTO [GoldenClub].[tbl_PlayerTracking]
SELECT
	@gaming,
	ISNULL(ING.CustomerID,
		ISNULL(euroIn.CustomerID,
			ISNULL(euroOut.CustomerID,
				ISNULL(LRDregIn.CustomerID,
					ISNULL(LRDregOut.CustomerID,
						ISNULL(ass.CustomerID,
							ISNULL(ev.CustomerID,
								ISNULL(cc.CustomerID,0)
								)
							)
						)
					)
				)
			)
		) AS CustomerID,
ing.PrimoIngresso		, 
ing.UltimoIngresso		, 
ing.TotIngressi			,
euroIn.PrimoEuroIn		, 
euroIn.UltimoEuroIn		, 
euroIn.CountEuroIn		, 
euroIn.TotEuroInSfr		, 
euroOut.PrimoEuroOut	,	
euroOut.UltimoEuroOut	, 
euroOut.CountEuroOut	,	
euroOut.TotEuroOutSfr	, 
LRDregIn.PrimaRegIn		,
LRDregIn.UltimaRegIn	,
LRDregIn.CountRegIn		,
LRDregIn.TotRegInSfr	,
LRDregOut.PrimaRegOut	,
LRDregOut.UltimaRegOut	,
LRDregOut.CountRegOut	,
LRDregOut.TotRegOutSfr	,
ass.PrimoAss			, 
ass.UltimoAss			, 
ass.CountAss			, 
ass.TotAssSfr			,
cc.PrimoCC				, 
cc.UltimoCC				, 
cc.CountCC				, 
cc.TotCCSfr				,
ev.TotPartecipazioniEvento, 
ev.PrimaPartecipazione	, 
ev.UltimaPartecipazione	,
ev.Accompagnati			
FROM         
(
	SELECT     
	CustomerID, 
	MIN(e.entratatimestampLoc) AS PrimoIngresso, 
	MAX(e.entratatimestampLoc) AS UltimoIngresso, 
	COUNT(*) AS TotIngressi
	FROM  Reception.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE GamingDate = @gaming
	and s.SiteTypeID = 2 --IsSesamEntrance
	AND IsUscita = 0
	GROUP BY CustomerID
) AS ing 
FULL outer JOIN 
(
	SELECT     
	CustomerID, 
	GeneralPurpose.fn_UTCToLocal(1,MIN(InsertTimestamp)) AS PrimoEuroIn, 
	GeneralPurpose.fn_UTCToLocal(1,MAX(InsertTimestamp)) AS UltimoEuroIn, 
	COUNT(*) AS CountEuroIn, 
	SUM(CAST(ImportoEuroCents AS FLOAT) / 100 * [ExchangeRate]) AS TotEuroInSfr
	FROM    Accounting.tbl_EuroTransactions t
	INNER JOIN Accounting.tbl_LifeCycles lf ON t.LifeCycleID = lf.LifeCycleID 
	WHERE   t.OpTypeID = 11 --only cambios
	and t.CancelID is NULL
	AND lf.GamingDate = @gaming
	AND CustomerID IS NOT NULL
	AND [PhysicalEuros] = 1
	GROUP BY CustomerID
) AS euroIn ON euroIn.CustomerID = ing.CustomerID 
full OUTER JOIN
(
	SELECT     
	CustomerID, 
	GeneralPurpose.fn_UTCToLocal(1,MIN(InsertTimestamp)) AS PrimoEuroOut, 
	GeneralPurpose.fn_UTCToLocal(1,MAX(InsertTimestamp)) AS UltimoEuroOut, 
	COUNT(*) AS CountEuroOut, 
	SUM(CAST(ImportoEuroCents AS FLOAT) / 100 *[ExchangeRate]) AS TotEuroOutSfr
	FROM    Accounting.tbl_EuroTransactions t
	INNER JOIN Accounting.tbl_LifeCycles lf ON t.LifeCycleID = lf.LifeCycleID 
	WHERE   t.OpTypeID in( 12,13) --redemption e vendite
	and t.CancelID is NULL
	AND lf.GamingDate = @gaming
	AND CustomerID IS NOT NULL
	AND [PhysicalEuros] = 1
	AND CustomerID IS NOT null
	GROUP BY CustomerID
) AS euroOut  ON euroOut.CustomerID = ing.CustomerID OR euroOut.CustomerID = euroIn.CustomerID
FULL OUTER JOIN
(
	SELECT     
	CustomerID, 
	MIN(reg.TimeStampUTC)	AS PrimaRegIn, 
	MAX(reg.TimeStampUTC)	AS UltimaRegIn, 
	COUNT(*)				AS CountRegIn, 
	SUM(reg.AmountSFr)		AS TotRegInSfr
	FROM   Snoopy.tbl_Registrations reg
	inner join Snoopy.tbl_IDCauses ide on ide.IDCauseID = reg.CauseID	
	WHERE GamingDate = @gaming
	AND  (ide.Direction = 'CashIn')
	AND ide.DenoID IS NOT null
	GROUP BY CustomerID
) AS LRDregIn ON LRDregIn.CustomerID = euroIn.CustomerID OR LRDregIn.CustomerID = euroOut.CustomerID OR LRDregIn.CustomerID = ing.CustomerID
FULL OUTER JOIN
(
	SELECT     
	CustomerID, 
	MIN(reg.TimeStampUTC)	AS PrimaRegOut, 
	MAX(reg.TimeStampUTC)	AS UltimaRegOut, 
	COUNT(*)				AS CountRegOut, 
	SUM(reg.AmountSFr)		AS TotRegOutSfr
	FROM   Snoopy.tbl_Registrations reg
	inner join Snoopy.tbl_IDCauses ide on ide.IDCauseID = reg.CauseID	
	WHERE GamingDate = @gaming
	AND  (ide.Direction = 'CashOut')
	AND ide.DenoID IS NOT null
	GROUP BY CustomerID
) AS LRDregOut ON LRDregOut.CustomerID = euroIn.CustomerID OR LRDregOut.CustomerID = euroOut.CustomerID OR LRDregOut.CustomerID = ing.CustomerID OR LRDregOut.CustomerID = LRDregIn.CustomerID
FULL OUTER JOIN
(
	SELECT     
	CustomerID, 
	MIN(EMISS.OraLoc) AS PrimoAss, 
	MAX(EMISS.OraLoc) AS UltimoAss, 
	COUNT(*)			AS CountAss, 
	SUM(EMISS.Quantity * EMISS.Denomination * EMISS.ExchangeRate) AS TotAssSfr
	FROM Snoopy.tbl_Assegni a 
	INNER JOIN Snoopy.vw_AllCustomerTransactionDenominations EMISS
						ON a.FK_EmissCustTransID = EMISS.CustomerTransactionID 
						and EMISS.CustTRCancelID is null
						and EMISS.OpTypeID = 9 --cambio assegni	
	WHERE EMISS.SourceGamingDate = @gaming
	GROUP BY CustomerID
) AS ass ON ass.CustomerID = euroIn.CustomerID OR ass.CustomerID = euroOut.CustomerID OR ass.CustomerID = ing.CustomerID OR ass.CustomerID = LRDregIn.CustomerID OR ass.CustomerID = LRDregOut.CustomerID 
FULL OUTER JOIN
(
	SELECT     
	CustomerID, 
	MIN(EMISS.OraLoc)	AS PrimoCC, 
	MAX(EMISS.OraLoc)	AS UltimoCC, 
	COUNT(*)			AS CountCC, 
	SUM(EMISS.Quantity * EMISS.Denomination * EMISS.ExchangeRate) AS TotCCSfr
	FROM [Snoopy].tbl_CartediCredito a 
	INNER JOIN Snoopy.vw_AllCustomerTransactionDenominations EMISS
						ON a.[FK_CustomerTransactionID]= EMISS.CustomerTransactionID 
						and EMISS.CustTRCancelID is null
						and EMISS.OpTypeID = 10 --Carta di credito
	WHERE EMISS.SourceGamingDate = @gaming AND EMISS.CustomerID > 1
	GROUP BY CustomerID
) AS cc ON cc.CustomerID = euroIn.CustomerID OR cc.CustomerID = euroOut.CustomerID OR cc.CustomerID = ing.CustomerID OR cc.CustomerID = LRDregIn.CustomerID OR cc.CustomerID = LRDregOut.CustomerID OR cc.CustomerID = ass.CustomerID
FULL OUTER JOIN	
(
	SELECT  
	g.CustomerID,   
	COUNT(*) AS [TotPartecipazioniEvento], 
	GeneralPurpose.fn_UTCToLocal(1, MIN(g.TimeStampUTC)) AS PrimaPartecipazione, 
	GeneralPurpose.fn_UTCToLocal(1, MAX(g.TimeStampUTC)) AS UltimaPartecipazione,
	max([Accompagnatori]) as Accompagnati
	FROM GoldenClub.tbl_PartecipazioneEventi AS g 
	INNER JOIN	Marketing.tbl_Eventi AS ev ON ev.EventoID = g.EventoID
	WHERE ev.GamingDate = @gaming
	--where ev.[DragonAndGolden] = 2
	GROUP BY g.CustomerID
) AS ev ON ev.CustomerID = euroIn.CustomerID OR ev.CustomerID = euroOut.CustomerID OR ev.CustomerID = ing.CustomerID OR ev.CustomerID = LRDregIn.CustomerID OR ev.CustomerID = LRDregOut.CustomerID OR ev.CustomerID = cc.CustomerID OR ev.CustomerID = ass.CustomerID


RETURN @@ROWCOUNT
GO
