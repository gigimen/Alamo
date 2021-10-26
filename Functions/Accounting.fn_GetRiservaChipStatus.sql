SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE FUNCTION [Accounting].[fn_GetRiservaChipStatus] ()
/*

select * from [Accounting].[fn_GetRiservaChipStatus] ()

*/
RETURNS @ChipsStatus TABLE (
	LifeCycleID			INT,
	GamingDate			DATETIME, 
	IsToday				BIT,
	Denomination		FLOAT,
	DenoID				INT, 
	FDescription		varchar(64),
	ValueTypeID			INT, 
	[CurrencyAcronim]	NVARCHAR(3),
	Apertura			INT,
	VersamentiDaMS		INT,
	PrelieviDaMS		INT,
	MovimentoDotazione	INT,
	Stato				INT
	)
AS
BEGIN

DECLARE    @LifeCycleID INT,@IsToday BIT,@GamingDate datetime

SELECT 
@LifeCycleID = LifeCycleID,
@GamingDate = GamingDate,
@IsToday = 
CASE 
WHEN GamingDate = [GeneralPurpose].[fn_GetGamingLocalDate2] 
(
GETDATE(),0,6 --riserva stock type
) THEN 1
ELSE 0
END
FROM Accounting.tbl_LifeCycles 
WHERE StockID = 32 --riserva
AND GamingDate = 
(
SELECT MAX(GamingDate) FROM Accounting.vw_AllStockLifeCycles WHERE StockID = 32
)

--SELECT @LifeCycleID AS 'LifeCycleID',@IsToday AS [ISTocday],@GamingDate AS '@GamingDate'

INSERT INTO @ChipsStatus
(
    LifeCycleID,
    GamingDate,
    IsToday,
    Denomination,
    DenoID,
	FDescription,
    ValueTypeID,
    CurrencyAcronim,
    Apertura,
    VersamentiDaMS,
    PrelieviDaMS,
    MovimentoDotazione,
    Stato
)
SELECT 
    @LifeCycleID,
    @GamingDate,
    @IsToday,
    t.Denomination,
    t.DenoID,
	t.FDescription,
    t.ValueTypeID,
    t.CurrencyAcronim,
    t.Apertura,
	t.FillsFromMe			AS VersamentiDaMS,
	t.CreditsFromMe			AS PrelieviDaMS,
	ISNULL(dot.Quantity,0)	AS MovimentoDotazione,
	ISNULL(dot.Quantity,0) + t.Stato AS Stato
FROM [Accounting].[fn_GetTableChipStatus](@LifeCycleID) t
LEFT OUTER JOIN 
(
	SELECT 
	DenoID,
	ValueTypeID,
	SourceLifeCycleID,
	SUM(CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END * Quantity) AS Quantity
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 18
	GROUP BY
	DenoID,
	ValueTypeID,
	SourceLifeCycleID
) dot
ON t.LifeCycleID = dot.SourceLifeCycleID AND dot.DenoID = t.denoid AND t.ValueTypeID = dot.ValueTypeID


RETURN
END
GO
