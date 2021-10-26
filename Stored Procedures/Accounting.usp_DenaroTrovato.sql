SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   PROCEDURE [Accounting].[usp_DenaroTrovato]
@GamingDate				DATETIME,
@EURCents				INT,
@CHFCents				INT,
@UserAccessID			INT,
@RitrovamentoOraLoc		DATETIME,
@LuogoRitrovo			VARCHAR(150),
@Osservazioni			VARCHAR(150),
@Trovatore				VARCHAR(150),
@Inf10chf				BIT,
@RapportoSurv			INT,
@CustomerID				INT,
@pk_DenaroTrovatoID		INT OUTPUT,
@pk_RestituzioneID		INT OUTPUT
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


declare @ret INT
set @ret = 0

IF @CustomerID IS NOT NULL
begin
	IF NOT EXISTS (SELECT CustomerID FROM Snoopy.tbl_Customers WHERE CustomerID = @CustomerID AND CustCancelID IS NULL)
	BEGIN
		RAISERROR('Invalid CustomerID (%d) specified or Customer is not Golden Member',16,1,@CustomerID)
		RETURN (1)
	END

	IF @pk_DenarotrovatoID IS NOT NULL AND @RapportoSurv IS NOT NULL 
	BEGIN
		IF EXISTS (SELECT [PK_RestituzioneID] FROM [Snoopy].[tbl_CustomerRestituzioni] WHERE [RappSorv]=@RapportoSurv AND FK_DenaroTrovatoID <> @pk_DenaroTrovatoID )
		BEGIN
			RAISERROR('Il rapporto di sorveglianza %d già assegnato ad altra restituzione!!',16,1,@RapportoSurv)
			RETURN (1)
		END
	END
END
/*
DECLARE @gtemp DATETIME
SELECT @gtemp = GeneralPurpose.fn_GetGamingDate(@RitrovamentoOraLoc,0,DEFAULT)

IF @gtemp <> @GamingDate
begin
	raiserror('Invalid ora specified',16,1)
	RETURN 1
END
*/
BEGIN TRANSACTION trn_DenaroTrovato

BEGIN TRY  

	IF @pk_DenarotrovatoID IS NULL
	BEGIN
		--transaction does not exists insert it
		INSERT INTO [Accounting].[tbl_DenaroTrovato]
			   ([FK_UserAccessID]
			   ,[GamingDate]
			   ,[TimeStampUTC]
			   ,[CHFCents]
			   ,[EURCents]
			   ,[LuogoRitrovo]
			   ,[Osservazioni]
			   ,[Trovatore]
			   ,[ImportiInf10])
		 VALUES
			   (@UserAccessID
			   ,@GamingDate
			   ,GeneralPurpose.fn_UTCToLocal(0,@RitrovamentoOraLoc)
			   ,@CHFCents
			   ,@EURCents
			   ,@LuogoRitrovo	
			   ,@Osservazioni	
			   ,@Trovatore		
			   ,@Inf10chf)

		SET @pk_DenarotrovatoID = SCOPE_IDENTITY()

		IF @CustomerID IS NOT NULL
		BEGIN
			--insert also restituzione in restituzione table
				INSERT INTO [Snoopy].[tbl_CustomerRestituzioni]
						   ([CustomerID]
						   ,RappSorv
						   ,[FK_DenaroTrovatoID]
						   )
					 VALUES
						   (@CustomerID
							,@RapportoSurv
						   ,@pk_DenarotrovatoID)
				SET @pk_RestituzioneID = SCOPE_IDENTITY()
		END

	END
	ELSE
	BEGIN

		UPDATE [Accounting].[tbl_DenaroTrovato]
		   SET [FK_UserAccessID] = @UserAccessID
			  ,[GamingDate]		= @GamingDate
--			  ,[NumeroRapporto] = @NrRapporto
			  ,[TimeStampUTC]	= GeneralPurpose.fn_UTCToLocal(0,@RitrovamentoOraLoc)
			  ,[CHFCents]		= @CHFCents
			  ,[EURCents]		= @EURCents
			  ,[LuogoRitrovo]	= @LuogoRitrovo	
			  ,[Osservazioni]	= @Osservazioni	
			  ,[Trovatore]		= @Trovatore		
			  ,[ImportiInf10]	= @Inf10chf
		WHERE [PK_DenaroTrovatoID] = @pk_DenarotrovatoID

		IF @CustomerID IS NOT NULL
		BEGIN
			IF NOT EXISTS ( SELECT [PK_RestituzioneID]  FROM [Snoopy].[tbl_CustomerRestituzioni]	WHERE [FK_DenaroTrovatoID] = @pk_DenarotrovatoID)
			BEGIN
				--insert also restituzione in restituzione table
				INSERT INTO [Snoopy].[tbl_CustomerRestituzioni]
						   ([CustomerID]
						   ,RappSorv
						   ,[FK_DenaroTrovatoID]
						   )
					 VALUES
						   (@CustomerID
							,@RapportoSurv
						   ,@pk_DenarotrovatoID)
				SET @pk_RestituzioneID = SCOPE_IDENTITY()
			END
			ELSE 
			BEGIN
				--get the relativerestituzione
				SELECT @pk_RestituzioneID = PK_RestituzioneID 
				FROM [Snoopy].[tbl_CustomerRestituzioni] 
				WHERE [FK_DenaroTrovatoID]= @pk_DenaroTrovatoID

				--update the customer
				UPDATE [Snoopy].[tbl_CustomerRestituzioni]
					SET [CustomerID] = @CustomerID,RappSorv = @RapportoSurv
				WHERE PK_RestituzioneID = @pk_RestituzioneID

			END				
		
		END
		ELSE
        BEGIN
			--se esisteva cancellala
			IF EXISTS ( SELECT [PK_RestituzioneID]  FROM [Snoopy].[tbl_CustomerRestituzioni]	WHERE [FK_DenaroTrovatoID] = @pk_DenarotrovatoID)
				--DELETE restituzione in restituzione table
				DELETE FROM [Snoopy].[tbl_CustomerRestituzioni]
				WHERE [FK_DenaroTrovatoID]= @pk_DenarotrovatoID
        END
	END

	COMMIT TRANSACTION trn_DenaroTrovato

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DenaroTrovato	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
