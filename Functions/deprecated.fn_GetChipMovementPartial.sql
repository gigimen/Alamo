SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [deprecated].[fn_GetChipMovementPartial]
(
    @gaming DATETIME,
	@oggi VARCHAR(16)
)
/*

select * from [ForIncasso].[fn_GetChipMovementPartial] ('6.30.2019','OGGI')

*/
RETURNS @RifList TABLE (ForIncassoTag VARCHAR(32), Amount INT)
--WITH SCHEMABINDING
AS
BEGIN

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('4.4.2019' ,'OGGI')
 execute [ForIncasso].[usp_ChipMovement] '5.3.2019' ,'IERI'
 

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '6.23.2019'
set 	@oggi = 'OGGI'


--*/



INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
/*

DECLARE @oggi VARCHAR(16)

SET @oggi = 'OGGI'
--*/
--INsert tavoli
SELECT 	'CHIPMOV_' + tav.Acronim + '_' + @oggi + '_TAV_' + cast (tav.denoid AS VARCHAR(16) ) AS ForIncassoTag,
	(tav.Apertura ) AS Amount
--SELECT a.*,b.*
FROM 
(	
	SELECT 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END AS DenoID,
	Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,1)  --TAVOLI
	 GROUP BY 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END,
	Acronim
) tav

--insert SMT
INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
/*

DECLARE @oggi VARCHAR(16)

SET @oggi = 'OGGI'
--*/

SELECT 	'CHIPMOV_' + smt.Acronim + '_' + @oggi + '_SMT_' + cast (smt.denoid AS VARCHAR(16) ) AS ForIncassoTag,
	(smt.Apertura) AS Amount
--SELECT a.*,b.*
FROM 
(
	SELECT 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END AS DenoID,
	Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,3)  --SMT
	 GROUP BY 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END,
	Acronim
) smt


DECLARE @MSStatus TABLE (DenoID INT, Acronim VARCHAR(32), Amount INT)

--se MS è stato chiuso usa la funzione [ForIncasso].[fn_GetChipsRipristinati]
IF EXISTS (	SELECT LifeCycleSnapshotID FROM Accounting.vw_AllSnapshots 
			WHERE GamingDate = @gaming AND StockID = 31 --MS
			AND SnapshotTypeID = 3 --chiusura
			)
BEGIN

	INSERT INTO @MSStatus
	(
		DenoID,
		Acronim,
		Amount
	)
	SELECT 
		CASE 
		WHEN DenoID in(1,128,195) THEN 1
		WHEN DenoID in(2,129,196) THEN 2
		WHEN DenoID in(3,130,197) THEN 3
		WHEN DenoID in(4,131,198) THEN 4
		WHEN DenoID in(5,132,199) THEN 5
		WHEN DenoID in(6,133,200) THEN 6
		WHEN DenoID in(7,134,201) THEN 7
		WHEN DenoID in(8,135,202) THEN 8
		WHEN DenoID in(9,136,203) THEN 9 
		ELSE DenoID
		END AS DenoID,
		Acronim,
		SUM(Chiusura) + SUM(Ripristino) AS Apertura
		from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,2)  --MS
		 GROUP BY 
		CASE 
		WHEN DenoID in(1,128,195) THEN 1
		WHEN DenoID in(2,129,196) THEN 2
		WHEN DenoID in(3,130,197) THEN 3
		WHEN DenoID in(4,131,198) THEN 4
		WHEN DenoID in(5,132,199) THEN 5
		WHEN DenoID in(6,133,200) THEN 6
		WHEN DenoID in(7,134,201) THEN 7
		WHEN DenoID in(8,135,202) THEN 8
		WHEN DenoID in(9,136,203) THEN 9 
		ELSE DenoID
		END,
		Acronim
END
ELSE
BEGIN
/*da modificare per prendere i valori da apertura, consegna,ripristini e conteggi
	

	DECLARE @gaming DATETIME
	SET @gaming = '11.16.2019'


--*/	
	INSERT INTO @MSStatus
	(
		DenoID,
		Acronim,
		Amount
	)
/*
	

	DECLARE @gaming DATETIME
	SET @gaming = '11.16.2019'


--*/	
	SELECT 
			CASE 
			WHEN d.DenoID IN(1,128,195) THEN 1
			WHEN d.DenoID IN(2,129,196) THEN 2
			WHEN d.DenoID IN(3,130,197) THEN 3
			WHEN d.DenoID IN(4,131,198) THEN 4
			WHEN d.DenoID IN(5,132,199) THEN 5
			WHEN d.DenoID IN(6,133,200) THEN 6
			WHEN d.DenoID IN(7,134,201) THEN 7
			WHEN d.DenoID IN(8,135,202) THEN 8
			WHEN d.DenoID IN(9,136,203) THEN 9 
			ELSE d.DenoID
			END AS DenoID,
			d.CurrencyAcronim			AS Acronim,
			SUM(ISNULL(ap.Quantity,0)	)+
			SUM(ISNULL(con.Quantity,0)	)-
			SUM(ISNULL(rip.Quantity,0)	)+
			SUM(ISNULL(cont.Quantity,0)	)	AS Apertura
		FROM CasinoLayout.vw_AllDenominations d
		FULL OUTER JOIN
		(
			SELECT GamingDate,DenoID,Denomination,Quantity 
			FROM Accounting.vw_AllSnapshotDenominations 
			WHERE StockID = 31 AND SnapshotTypeID = 5  --conteggio entrata
			AND ValueTypeID IN(1,36,42) AND DenoID NOT IN (78,95,96,97) --forget about lucky and medaglie
			AND GamingDate = @gaming
		) ap ON ap.DenoID = d.DenoID
		FULL OUTER JOIN 
		(
			--all consegne
			SELECT SourceGamingDate AS Gamingdate,DenoID,Denomination,
			SUM(Quantity) AS Quantity 
			FROM Accounting.vw_AllTransactionDenominations 
			WHERE DestStockID = 31 --AND --consegne
			AND ValueTypeID IN(1,36,42) AND DenoID NOT IN (78,95,96,97) --forget about lucky and medaglie
			AND OpTypeID = 6 --consegna
			AND SourceGamingDate = @gaming
			GROUP BY SourceGamingDate,DenoID,Denomination
		) con ON con.DenoID = d.DenoID
		FULL OUTER JOIN 
		(
			--all ripristini
			SELECT SourceGamingDate AS Gamingdate,DenoID,Denomination,
			SUM(Quantity) AS Quantity 
			FROM Accounting.vw_AllTransactionDenominations 
			WHERE SourceStockID = 31 --AND --consegne
			AND ValueTypeID IN(1,36,42) AND DenoID NOT IN (78,95,96,97) --forget about lucky and medaglie
			AND OpTypeID = 5 --ripristini
			AND SourceGamingDate = @gaming
			GROUP BY SourceGamingDate,DenoID,Denomination
		) rip ON rip.DenoID = d.DenoID
		FULL OUTER JOIN
		(
			SELECT 
				GamingDate,
				DenoID,
				SUM(Quantity) AS Quantity
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE SnapshotTypeID NOT IN (14,15) 
			AND ValueTypeID IN (1,36,42)
			AND	GamingDate = @gaming
			GROUP BY  GamingDate,DenoID

	
		) cont ON d.DenoID = cont.DenoID
		WHERE d.DenoID IN(1,2,3,4,5,6,7,8,9,128,129,130,131,132,133,134,135,136,195,196,197,198,199,200,201,202,203)  
		 GROUP BY 
			CASE 
			WHEN d.DenoID IN(1,128,195) THEN 1
			WHEN d.DenoID IN(2,129,196) THEN 2
			WHEN d.DenoID IN(3,130,197) THEN 3
			WHEN d.DenoID IN(4,131,198) THEN 4
			WHEN d.DenoID IN(5,132,199) THEN 5
			WHEN d.DenoID IN(6,133,200) THEN 6
			WHEN d.DenoID IN(7,134,201) THEN 7
			WHEN d.DenoID IN(8,135,202) THEN 8
			WHEN d.DenoID IN(9,136,203) THEN 9 
			ELSE d.DenoID
			END,
			d.CurrencyAcronim	


END

--insert casse,CC,MS e riserva
INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
/*

DECLARE @oggi VARCHAR(16)

SET @oggi = 'OGGI'
--*/
SELECT 	'CHIPMOV_' + cass.Acronim + '_' + @oggi + '_CAS_' + cast (cass.denoid AS VARCHAR(16) ) AS ForIncassoTag,
	(cass.Apertura + CC.Apertura + ms.Amount + ris.Apertura) AS Amount
--SELECT a.*,b.*,c.*,d.*
FROM 
(	
	SELECT 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END AS DenoID,
	Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,4)  --CASSE
	 GROUP BY 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END,
	Acronim
) cass
FULL OUTER JOIN 
(
	SELECT 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END AS DenoID,
	Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,7)  --CC
	 GROUP BY 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END,
	Acronim
) CC ON CC.denoid = cass.denoid AND cass.Acronim = CC.Acronim
FULL OUTER JOIN @MSStatus ms ON ms.denoid = cass.denoid AND ms.Acronim = cass.Acronim
FULL OUTER JOIN 
(
	SELECT 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END AS DenoID,
	Acronim,
	SUM(Chiusura) + SUM(Ripristino) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,6)  --RISERVA
	 GROUP BY 
	CASE 
	WHEN DenoID in(1,128,195) THEN 1
	WHEN DenoID in(2,129,196) THEN 2
	WHEN DenoID in(3,130,197) THEN 3
	WHEN DenoID in(4,131,198) THEN 4
	WHEN DenoID in(5,132,199) THEN 5
	WHEN DenoID in(6,133,200) THEN 6
	WHEN DenoID in(7,134,201) THEN 7
	WHEN DenoID in(8,135,202) THEN 8
	WHEN DenoID in(9,136,203) THEN 9 
	ELSE DenoID
	END,
	Acronim
) ris ON ris.denoid = cass.denoid AND ris.Acronim = cass.Acronim



--insert anche dotazione nel report

INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)
SELECT 
'CHIPMOV_' + a.Acronim + '_' + @oggi + '_DOT_' + a.Deno AS ForIncassoTag,
a.Amount	
FROM
(

/*

declare @gaming  datetime
set		@gaming = N'6.23.2020'
--*/

SELECT  
CASE 
WHEN DenoID IN(1,128,195) THEN '1'
WHEN DenoID IN(2,129,196) THEN '2'
WHEN DenoID IN(3,130,197) THEN '3'
WHEN DenoID IN(4,131,198) THEN '4'
WHEN DenoID IN(5,132,199) THEN '5'
WHEN DenoID IN(6,133,200) THEN '6'
WHEN DenoID IN(7,134,201) THEN '7'
WHEN DenoID IN(8,135,202) THEN '8' 
WHEN DenoID IN(9,136,203) THEN '9' 
ELSE CAST (denoid AS VARCHAR(16) )
END								AS Deno
		,CurrencyAcronim		AS Acronim
--		,SUM(Quantity)			AS Amount
--FROM [Accounting].[vw_AllConteggiDenominations]
--WHERE [SnapshotTypeID] = 17 --Conteggio dotazione gettoni
--AND gamingdate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
		,SUM(ABS(Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) ) AS Amount
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
	AND SourceGamingDate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
	AND DenoID NOT IN (78,10,95,96,97)  --forget about lucy chip and 500 chf and medaglie

GROUP BY CASE 
WHEN DenoID IN(1,128,195) THEN '1'
WHEN DenoID IN(2,129,196) THEN '2'
WHEN DenoID IN(3,130,197) THEN '3'
WHEN DenoID IN(4,131,198) THEN '4'
WHEN DenoID IN(5,132,199) THEN '5'
WHEN DenoID IN(6,133,200) THEN '6'
WHEN DenoID IN(7,134,201) THEN '7'
WHEN DenoID IN(8,135,202) THEN '8' 
WHEN DenoID IN(9,136,203) THEN '9' 
ELSE CAST (denoid AS VARCHAR(16) )
END
,CurrencyAcronim
		
) a
RETURN

END
GO
