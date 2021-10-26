SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Snoopy].[usp_NewLRDCustomerDocPDF] 
@uaid as int,
@custID as int ,
@GamingDate as datetime,
@PDFID as int output,
@fileSize as int,
@filename as varchar(256),
@fileImage as image,
@timestamp as datetime output
AS

--corretto il case
if not exists (select IdentificationID from Snoopy.tbl_Identifications i where i.CustomerID = @custID)
begin
	raiserror('Invalid CustomerID (%d) specified',16,1,@custID)
	return(1)
end

set @timestamp = getUTCDate()

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDCustomerDoc

BEGIN TRY  



	if @PDFID is not null and exists (select PDFID from Snoopy.tbl_CustomerDocPDF where PDFID = @PDFID)
	begin

		Update Snoopy.tbl_CustomerDocPDF
		set CustomerID 			= @custID,
			OriginalFileName	= @filename,
			InsertUserAccessID	= @uaid,
			InsertTimeStampUTC	= @timestamp,
			GamingDate 			= @GamingDate
		where PDFID = @PDFID

		Update [Giotto].Snoopy.CustomerDocPDF
		set CustomerID 			= @custID,
			PDFfile 			= @fileImage,
			PDFFileSize			= @fileSize
		where PDFID = @PDFID

	end
	else
	begin
		INSERT INTO Snoopy.tbl_CustomerDocPDF
		(
			CustomerID,
			OriginalFileName,
			InsertUserAccessID,
			InsertTimeStampUTC,
			GamingDate
		)
		values
		(
			@custID,
			@filename,
			@uaid,
			@timestamp,
			@GamingDate
		)

		set @PDFID = scope_identity()

		INSERT INTO [Giotto].Snoopy.CustomerDocPDF
		(
			PDFID,
			CustomerID,
			PDFfile,
			PDFFileSize
		)
		values
		(
			@PDFID,
			@custID,
			@fileImage,
			@fileSize
		)
	END

	set @timestamp = GeneralPurpose.fn_UTCToLocal(1,@timestamp)



	COMMIT TRANSACTION trn_NewLRDCustomerDoc

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDCustomerDoc
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
