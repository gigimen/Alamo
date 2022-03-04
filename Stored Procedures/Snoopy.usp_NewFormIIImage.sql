SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [Snoopy].[usp_NewFormIIImage] 
@identificationID as int,
@uaid as int,
@timestamp as datetime output,
@ImageBin AS IMAGE,
@OriginalSize AS INT
AS
if @identificationID Is null or @identificationID = 0
begin
	raiserror('Invalid IdentificationID (%d) specified ',16,1,@identificationID)
	return 1
end

DECLARE @ret int


set @ret = 0

BEGIN TRANSACTION trn_NewFormIIImage

BEGIN TRY  

	set @timestamp = getUTCDate()
	DECLARE @custID int
	DECLARE @GamingDate datetime
	DECLARE @PDFID int
	DECLARE @filename varchar(256)
	DECLARE @origUAID int

	SELECT @custID = CustomerID FROM Snoopy.tbl_Identifications WHERE IdentificationID = @identificationID

	if exists (select IdentificationID from Giotto.Snoopy.ImmaginiFormII where IdentificationID = @identificationID)
	BEGIN
		--first save old formII image
		SELECT 
			@origUAID = InsertUserAccessID,
			@GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(InsertTimeStampUTC,1,7)
		FROM Giotto.Snoopy.ImmaginiFormII
		where IdentificationID = @identificationID
	
		SELECT @filename = 'FormII del ' + CONVERT(VARCHAR(32),@GamingDate,105) + '.jpg'

		--insert doc in in table
		INSERT INTO Snoopy.tbl_CustomerDocPDF
		(
			CustomerID,
			OriginalFileName,
			InsertUserAccessID,
			InsertTimeStampUTC,
			GamingDate
		)
		SELECT 
			@custID,
			@filename,
			InsertUserAccessID,
			InsertTimeStampUTC,
			GeneralPurpose.fn_GetGamingLocalDate2(InsertTimeStampUTC,1,7)
		FROM Giotto.Snoopy.ImmaginiFormII
		where IdentificationID = @identificationID

		set @PDFID = IDENT_CURRENT( 'Snoopy.tbl_CustomerDocPDF' ) 

		--and its image in giotto
		INSERT INTO [Giotto].Snoopy.CustomerDocPDF
		(
			PDFID,
			CustomerID,
			PDFfile,
			PDFFileSize
		)
		SELECT 
			@PDFID,
			@custID,
			ImageBin,
			OriginalSize
		FROM Giotto.Snoopy.ImmaginiFormII
		where IdentificationID = @identificationID


		--finally update formII image
		Update Giotto.Snoopy.ImmaginiFormII
		set 
			ImageBin 			= @ImageBin,
			OriginalSize		= @OriginalSize,
			InsertTimeStampUTC	= @timestamp,
			InsertUserAccessID	= @uaid
		where IdentificationID	= @identificationID
	end
	else
	begin

		--new image to be inserted
		--first create the image record
		INSERT INTO Giotto.Snoopy.ImmaginiFormII
		(
			IdentificationID,
			ImageBin,
			OriginalSize,
			InsertTimeStampUTC,
			InsertUserAccessID
		)
		values
		(
			@identificationID,
			@ImageBin,
			@OriginalSize,
			@timestamp,
			@uaid
		)
	END

	COMMIT TRANSACTION trn_NewFormIIImage
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewFormIIImage
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
