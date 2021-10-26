SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [GeneralPurpose].[usp_MessaggioColpoTriplo]
@StockID int
AS

/*


declare @StockID int
set @StockID = 9

--*/

	--clear also table results
	DECLARE @retMsg NVARCHAR(4000)
	SELECT @retMsg = [GeneralPurpose].[fn_ColpoTriploOnCISDisplay] (s.Tag)
	from CasinoLayout.Stocks s
	where s.StockID = @StockID

	EXEC	[GeneralPurpose].[usp_BroadcastMessage]
			@type = N'wav',
			@attribs = N'filename=''colpotriplo.wav'''
	
	PRINT 'Message for colpotriplo sent'
GO
