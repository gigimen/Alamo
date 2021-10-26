SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetAllStocksStatusEx] 
@StockTypeID	INT,
@gaming			DATETIME,
@eurorate		FLOAT OUTPUT
AS


DECLARE @RC INT

SELECT @eurorate = IntRate FROM [Accounting].tbl_CurrencyGamingdateRates
WHERE CurrencyID = 0 --euros
AND gamingdate = @gaming

EXECUTE @RC = [Accounting].[usp_GetAllStocksStatus] 
   @StockTypeID
  ,@gaming

RETURN @RC


GO
