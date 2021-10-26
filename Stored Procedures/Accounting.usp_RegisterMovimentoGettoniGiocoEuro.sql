SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_RegisterMovimentoGettoniGiocoEuro] 
@CausaleID		INT,
@LifeCycleID	INT,
@DenoID			INT,
@totGettoni		INT,
@ExchangeRate 	FLOAT,
@transactionID	INT		OUTPUT,
@ExchangeTime	DATETIME OUTPUT
AS

set @ExchangeTime = GetUTCDate()

--get rid of milliseconds which are not neeeded
set @ExchangeTime = DATEADD(ms,-DATEPART(ms,@ExchangeTime),@ExchangeTime)


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_MovimentoGettoniGiocoEuro

BEGIN TRY  

	INSERT INTO [Accounting].[tbl_MovimentiGettoniGiocoEuro]
           ([LifeCycleID]
           ,[DenoID]
           ,[TotGettoni]
           ,[ExchangeRate]
           ,[ExchangeTimeUTC]
           ,[CausaleID])
		VALUES(
		@LifeCycleID		,
		@DenoID	,
		@totGettoni		,
		@ExchangeRate		,
		@ExchangeTime		,
		@CausaleID
		)

	SET @transactionID = SCOPE_IDENTITY()


	COMMIT TRANSACTION trn_MovimentoGettoniGiocoEuro

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_MovimentoGettoniGiocoEuro
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret

GO
