SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_ChipsStatus]
(
    @gaming DATETIME
)
/*

select * from [Accounting].[fn_ChipsStatus] ('12.31.2018')

*/
RETURNS @RifList TABLE (
	GamingDate		datetime,
	Denomination	INT,
	DenoID			INT,
	ValueTypeName	VARCHAR(32),
	ValueTypeID		INT,
	Acronim			VARCHAR(4),
	Tavoli			INT,
	SMT				INT,
	MS				INT,
	Riserva			INT,
	Casse			INT,
	Tecnici			INT,
	Dotazione		INT,
	Liability		INT
)



--WITH SCHEMABINDING
AS
BEGIN


DECLARE @ChipsTecnici TABLE (DenoID INT, Stato INT)

INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 4,20)
INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 5,20)
INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 6,20)
INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 7,20)
INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 8,20)
IF @gaming >= '7.3.2019'--first day with tecnic euro chips
begin
	INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 198,20)
	INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 199,20)
	INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 200,20)
	INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 201,20)
	INSERT INTO @ChipsTecnici (DenoID,Stato) VALUES( 202,20)
END

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('4.4.2019' ,'OGGI')
 execute [ForIncasso].[usp_ChipMovement] '5.3.2019' ,'IERI'
 

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '6.23.2019'
set 	@oggi = 'OGGI'


--*/
INSERT INTO @RifList
(
    GamingDate,
    Denomination,
    DenoID,
    ValueTypeName,
    ValueTypeID,
    Acronim,
    Tavoli,
    SMT,
    MS,
    Riserva,
    Casse,
	Tecnici,
    Dotazione,
    Liability
)

SELECT 
 @gaming AS GamingDate,
 tav.Denomination,
 tav.DenoID,
 tav.ValueTypeName,
 tav.ValueTypeID,
 tav.Acronim,
 tav.Stato AS Tavoli,
 smt.Stato AS SMT,
 ms.Stato	AS MS,
 ris.Stato	AS Riserva,
 cc.Stato + cass.Stato AS Casse,
 ISNULL(tec.Stato,0) AS Tecnici,
 ISNULL(dot.AmouStato,0) AS Dotazione,
 ISNULL(dot.AmouStato,0) - (tav.Stato + smt.Stato + ms.Stato + ris.Stato + cc.Stato + cass.Stato + ISNULL(tec.Stato,0)) AS Liability
from
(
SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim,SUM(Chiusura) + SUM(Ripristino) AS Stato FROM [ForIncasso].[fn_GetChipsRipristinati] (@gaming,1)  --TAVOLI
GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim
) tav
FULL OUTER JOIN 
(
SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim,SUM(Chiusura) + SUM(Ripristino) AS Stato FROM [ForIncasso].[fn_GetChipsRipristinati] (@gaming,3) 
GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim
) smt ON tav.DenoID = smt.DenoID
FULL OUTER JOIN 
(
SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim,SUM(Chiusura) + SUM(Ripristino) AS Stato FROM [ForIncasso].[fn_GetChipsRipristinati] (@gaming,2) 
GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim
) ms  ON tav.DenoID = ms.DenoID
FULL OUTER JOIN 
(
SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim,SUM(Chiusura) + SUM(Ripristino) AS Stato FROM [ForIncasso].[fn_GetChipsRipristinati] (@gaming,4) 
GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim
) cass ON cass.DenoID = tav.DenoID
FULL OUTER JOIN 
(
SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim,SUM(Chiusura) + SUM(Ripristino) AS Stato FROM [ForIncasso].[fn_GetChipsRipristinati] (@gaming,7) 
GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim
) cc ON tav.DenoID = cc.DenoID
FULL OUTER JOIN
(
SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim,SUM(Chiusura) + SUM(Ripristino) AS Stato FROM [ForIncasso].[fn_GetChipsRipristinati] (@gaming,6) 
GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,Acronim
) ris ON ris.DenoID = tav.DenoID
FULL OUTER JOIN @ChipsTecnici tec ON tec.DenoID = tav.DenoID
FULL OUTER JOIN
(
	/*
	SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,[CurrencyAcronim],SUM(Quantity)			AS AmouStato
	FROM [Accounting].[vw_AllConteggiDenominations]
	WHERE [SnapshotTypeID] = 17 --Conteggio dotazione gettoni
	AND GamingDate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
	AND DenoID NOT IN (78,10,95,96,97)  --forget about lucy chip and 500 chf and medaglie
	GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,[CurrencyAcronim]
	*/

	SELECT Denomination,DenoID,ValueTypeName,ValueTypeID,[CurrencyAcronim],	
		  SUM(ABS(Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END)) AS AmouStato
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
	AND SourceGamingDate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
	AND DenoID NOT IN (78,10,95,96,97)  --forget about lucy chip and 500 chf and medaglie
	GROUP BY Denomination,DenoID,ValueTypeName,ValueTypeID,[CurrencyAcronim]

) dot ON tav.DenoID = dot.DenoID
ORDER BY tav.ValueTypeID,tav.DenoID


RETURN

END
GO
