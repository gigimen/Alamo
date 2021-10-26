SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Snoopy].[usp_NewLRDDeleteCustomerDocPDF] 
@pdfID int
AS

declare @IdentificID int
select @IdentificID = IdentificationID 
from Snoopy.tbl_Identifications
where customerID in (
select CustomerID from Snoopy.tbl_CustomerDocPDF where PDFID = @pdfID
) 

if @IdentificID = null 
begin
	raiserror('Invalid pdfid (%d) specified',16,1,@pdfID)
	return (1)
end



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDDeleteCustomerDocPDF

BEGIN TRY  




	delete from Snoopy.tbl_CustomerDocPDF where PDFID = @pdfID

	--delete also in giotto database
	delete from Snoopy.tbl_CustomerDocPDF where PDFID = @pdfID

	COMMIT TRANSACTION trn_NewLRDDeleteCustomerDocPDF

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDDeleteCustomerDocPDF
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
