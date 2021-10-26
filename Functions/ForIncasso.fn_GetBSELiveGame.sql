SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE FUNCTION [ForIncasso].[fn_GetBSELiveGame] 
(
@from			DATETIME,
@to				DATETIME
)

---

/*

declare @from			DATETIME,@to				DATETIME

set @from	= '8.15.2019'
set @to		= '8.20.2019'

select * from [ForIncasso].[fn_GetBSELiveGame] 
(
@from			,
@to				
)
order by StockID,GamingDate

--*/
RETURNS   @BSELiveGame TABLE(
	[Tag] VARCHAR(16),
	[StockID]	INT,
	[LifeCycleID]	INT,
	[CurrencyID] INT,
	[GamingDate] DATETIME,
	[Fills] INT,
	[Credits] INT,
	[EstimatedDrop] INT,
	[totConteggio]  INT,
	[Apertura] INT,
	[Chiusura] INT,
	[Tronc] FLOAT,
	[BSE]	INT,
	LuckyChipsPezzi INT,
	LuckyChipsvalue INT,
	[EuroRate] FLOAT
) 
AS
BEGIN

	DECLARE @gaming DATETIME


	SET @gaming = @from

	WHILE @gaming <= @to
	BEGIN

		INSERT INTO @BSELiveGame
		(
			Tag,
			[StockID],
			[LifeCycleID],
			CurrencyID,
			GamingDate,
			Fills,
			Credits,
			EstimatedDrop,
			totConteggio,
			Apertura,
			Chiusura,
			Tronc,
			BSE,
			LuckyChipsPezzi ,
			LuckyChipsvalue ,
			[EuroRate]
		)
/*

DECLARE @gaming DATETIME

SET @gaming = '9.1.2019'

		SELECT     
			a.*,
			r.IntRate
		FROM [ForIncasso].[fn_GetTischeAbrechnung] (@gaming) a ,Accounting.tbl_CurrencyGamingdateRates r
		WHERE r.CurrencyID = 0 AND r.GamingDate = @gaming and ( a.LastGamingDate = @gaming or a.CashBox <> 0 or a.Tronc <> 0)
--*/
		SELECT     
			a.Tag + ' ' + LOWER(a.Acronim) AS Tag,
			a.StockID,
			a.LifeCycleID,
			a.CurrencyID,
			a.GamingDate,
			a.Fills,
			a.Credits,
			a.EstimatedDrop,
			a.CashBox,
			a.Apertura,
			a.Chiusura,
			a.Tronc,
			a.BSE,
			a.LuckyChipsPezzi,
			a.LuckyChipsValue,
			r.IntRate
		FROM [ForIncasso].[fn_GetTischeAbrechnung] (@gaming) a ,Accounting.tbl_CurrencyGamingdateRates r
		WHERE r.CurrencyID = 0 AND r.GamingDate = @gaming  
		AND 
		--either has been used on that day or some drop or trinc has been found in the box
		( a.LastGamingDate = @gaming or a.CashBox <> 0 or a.Tronc <> 0) 

		SET @gaming = DATEADD(DAY,1,@gaming)
	END
RETURN

END
GO
