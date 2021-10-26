SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE FUNCTION [Accounting].[fn_GetSMTChipStatus] ()
/*

select * from [Accounting].[fn_GetSMTChipStatus] ()

*/
RETURNS @ChipsStatus TABLE (
	LifeCycleID			INT,
	GamingDate			DATETIME, 
	IsToday				BIT,
	Denomination		float,
	DenoID				INT, 
	ValueTypeID			INT, 
	[CurrencyAcronim]	NVARCHAR(3),
	Apertura			INT,
	FillsTavoli			INT,
	CreditsTavoli		INT,
	CambioRicTavoli		INT,
	CambioConTavoli		INT,
	FillsCassa			INT,
	CreditsCassa		INT,
	CambioRicCassa		INT,
	CambioConcassa		INT,
	Stato				INT
	)
AS
BEGIN


DECLARE    @LifeCycleID INT,@IsToday BIT,@GamingDate datetime

SELECT 
@LifeCycleID = LifeCycleID,
@GamingDate = GamingDate,
@IsToday = 
case 
when GamingDate = [GeneralPurpose].[fn_GetGamingLocalDate2] 
(
GETDATE(),0,3 --SMT stock type
) then 1
else 0
end
FROM Accounting.tbl_LifeCycles 
WHERE StockID = 30 --SMT
AND GamingDate = 
(
SELECT MAX(GamingDate) FROM Accounting.vw_AllStockLifeCycles WHERE StockID = 30
)

--SELECT @LifeCycleID AS 'LifeCycleID',@IsToday AS [ISTocday],@GamingDate AS '@GamingDate'


INSERT INTO @ChipsStatus
(
    LifeCycleID,
    GamingDate,
    IsToday,
    Denomination,
    DenoID,
    ValueTypeID,
    CurrencyAcronim,
    Apertura,
    FillsTavoli,
    CreditsTavoli,
    CambioRicTavoli,
    CambioConTavoli,
    FillsCassa,
    CreditsCassa,
    CambioRicCassa,
    CambioConcassa,
    Stato
)
SELECT 
    @LifeCycleID,
    @GamingDate,
    @IsToday,
    t.Denomination,
    t.DenoID,
    t.ValueTypeID,
    t.CurrencyAcronim,
    t.Apertura,
	t.FillsToMe				,
	t.CreditsToMe			,
	t.CambioRicToMe			,
	t.CambioConToMe			,
	t.FillsFromMe			,
	t.CreditsFromMe			,
	t.CambioRicFromMe		,
	t.CambioConFromMe		,
	t.Stato
FROM [Accounting].[fn_GetTableChipStatus](@LifeCycleID) t

RETURN
END
GO
