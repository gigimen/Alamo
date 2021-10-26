SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [ForIncasso].[usp_GetTischeAbrechnung]
@gaming			DATETIME,
@EuroRate		FLOAT output
AS

/*
DECLARE	@return_value int,
		@EuroRate float

EXEC	@return_value = [ForIncasso].[usp_GetTischeAbrechnung]
		@gaming = N'6.1.2019',
		@EuroRate = @EuroRate OUTPUT

SELECT	@EuroRate as N'@EuroRate'

SELECT	'Return Value' = @return_value

--*/

--get last available euro rate from alamo database
DECLARE @ultimogiorno DATETIME
SELECT @ultimogiorno = MAX(gamingdate) FROM Accounting.tbl_CurrencyGamingdateRates 
WHERE GamingDate <= @gaming AND CurrencyID = 0
	
SELECT @eurorate = IntRate 
FROM Accounting.tbl_CurrencyGamingdateRates 
WHERE GamingDate = @ultimogiorno AND CurrencyID = 0

if 	@EuroRate is null 
begin
	raiserror('Non esiste il cambio euro del giorno specificato!!',16,-1)
	return (1)
end

SELECT     
	Tag + ' ' + LOWER(Acronim) AS Tag,
	CurrencyID,
	Acronim,
    GamingDate,
    Apertura,
    Chiusura,
    Fills,
    Credits,
    EstimatedDrop,
    CashBox,
    Tronc,
	LuckyChipsPezzi,
	LuckyChipsValue		
 from [ForIncasso].[fn_GetTischeAbrechnung] (@gaming)
GO
