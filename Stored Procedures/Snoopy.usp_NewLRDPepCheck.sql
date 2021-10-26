SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Snoopy].[usp_NewLRDPepCheck] 
@uaid int,
@custID int,
@regGamingDate datetime,
@fileSize int,
@fileImage image,
@pepcheckid int output,
@timestamp datetime output
AS


--corretto i case

set @timestamp = getUTCDate()



if @pepcheckid is not null and not exists (select PepCheckID from Snoopy.tbl_PepChecks where PepCheckID = @pepcheckid)
begin
	raiserror('Invalid PepCheckID (%d) specified',16,1,@pepcheckid)
	return (1)
end
else if @pepcheckid is null and exists (select PepCheckID from Snoopy.tbl_PepChecks where CustomerID = @custID and PepCheckYear = datepart(yy,@regGamingDate))
begin
	raiserror('PepCheck already done for this year for Customer (%d) specified',16,1,@custID)
	return (1)
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDPepChec

BEGIN TRY  



	if @pepcheckid is not null 
	begin
		Update Snoopy.tbl_PepChecks
		set CustomerID 			= @custID,
			InsertUserAccessID	= @uaid,
			InsertTimeStampUTC	= @timestamp,
			PepCheckYear		= datepart(yy,@regGamingDate)
		where PepCheckID = @pepcheckid

		Update [Giotto].Snoopy.PepChecks
		set CustomerID 			= @custID,
			PDFfile 			= @fileImage,
			PDFFileSize			= @fileSize
		where PepCheckID = @pepcheckid

	end
	else
	begin
		INSERT INTO Snoopy.tbl_PepChecks
		(
			CustomerID,
			InsertUserAccessID,
			InsertTimeStampUTC,
			PepCheckYear
		)
		values
		(
			@custID,
			@uaid,
			@timestamp,
			datepart(yy,@regGamingDate)
		)

		set @pepcheckid = @@IDENTITY
		INSERT INTO [Giotto].Snoopy.PepChecks
		(
			PepCheckID,
			CustomerID,
			PDFfile,
			PDFFileSize
		)
		values
		(
			@pepcheckid,
			@custID,
			@fileImage,
			@fileSize
		)

	end
	set @timestamp = GeneralPurpose.fn_UTCToLocal(1,@timestamp)


	COMMIT TRANSACTION trn_NewLRDPepChec

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDPepChec
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
