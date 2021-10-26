SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   PROCEDURE [Accounting].[usp_RestituzioneDiffCassa]
@GamingDate				DATETIME,
@StockID				INT,
@RespID					INT,
@Descrizione			VARCHAR(512),
@oraErrore				DATETIME,
@EURCents				INT,
@CHFCents				INT,
@UserAccessID			INT,
@RapportoSurv			INT,
@CustomerID				INT,
@RettificaRestituzioneID		INT OUTPUT
AS

IF @UserAccessID IS NULL OR @UserAccessID = 0
begin
	raiserror('Invalid @UserAccessID specified ',16,1)
	RETURN 1
END

IF (@EURCents IS NULL OR @EURCents = 0) AND (@CHFCents IS NULL OR @CHFCents = 0)
begin
	raiserror('Specify a valid importo',16,1)
	RETURN 1
END

IF @CustomerID IS NULL OR NOT EXISTS( SELECT CustomerID FROM Snoopy.tbl_Customers WHERE CustomerID = @CustomerID AND CustCancelID IS null)
begin
	raiserror('Invalid or null @CustomerID specified ',16,1)
	RETURN 1
END

IF @RespID IS NOT NULL AND NOT EXISTS (SELECT UserID FROM CasinoLayout.Users WHERE UserID = @RespID)
BEGIN
	raiserror('Invalid @RespID specified ',16,1)
	RETURN 1
END

declare @ret INT
set @ret = 0

/*
DECLARE @gtemp DATETIME
SELECT @gtemp = GeneralPurpose.fn_GetGamingDate(@RitrovamentoOraLoc,0,DEFAULT)

IF @gtemp <> @GamingDate
begin
	raiserror('Invalid ora specified',16,1)
	RETURN 1
END
*/
BEGIN TRANSACTION trn_RestituzioneDiffCassa

BEGIN TRY  

	IF @RettificaRestituzioneID IS NULL
	BEGIN
		--transaction does not exists insert it
		INSERT INTO [Accounting].[tbl_Rettifica_Restituzione]
			   ([FK_UserAccessID]
			   ,[GamingDate]
			  ,[FK_StockID]
			  ,[FK_RespID]
			   ,[EURCents]
			   ,[CHFCents]
			   ,[Descrizione]
			   ,[OraErroreUTC])
		 VALUES
			   (@UserAccessID
			   ,@GamingDate
				,@StockID
				,@RespID
				,@EURCents				
				,@CHFCents				
			   ,@Descrizione
			   ,GeneralPurpose.fn_UTCToLocal(0,@oraErrore))

		SELECT @RettificaRestituzioneID = SCOPE_IDENTITY()

		--insert also restituzione in restituzione table
		INSERT INTO [Snoopy].[tbl_CustomerRestituzioni]
					   ([CustomerID]
					   ,[FK_RettificaRestituzioneID]
					   ,[RappSorv])
				 VALUES
					   (@CustomerID
					   ,@RettificaRestituzioneID
					   ,@RapportoSurv)

	END
	ELSE
	BEGIN

		UPDATE [Accounting].[tbl_Rettifica_Restituzione]
		   SET [FK_UserAccessID] = @UserAccessID
			  ,[InsertTimeStampUTC] = GETUTCDATE()
			  ,[GamingDate]		= @GamingDate
			  ,[FK_StockID]		= @StockID
			  ,[FK_RespID]		= @RespID
			  ,[OraErroreUTC]	= GeneralPurpose.fn_UTCToLocal(0,@oraErrore)
			  ,[CHFCents]		= @CHFCents
			  ,[EURCents]		= @EURCents
			  ,[Descrizione]	= @Descrizione	
		WHERE [PK_RettificaRestituzioneID] = @RettificaRestituzioneID

		 --update the customer in restituzione table
		UPDATE [Snoopy].[tbl_CustomerRestituzioni]
			SET [CustomerID] = @CustomerID
			  ,[RappSorv]	= @RapportoSurv
		WHERE [FK_RettificaRestituzioneID]= @RettificaRestituzioneID
	END

	COMMIT TRANSACTION trn_RestituzioneDiffCassa

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RestituzioneDiffCassa	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
