SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Marketing].[usp_UpdateCustomerSector]
@CustID		int,
@SectorID	int
AS
--first some check on parameters
if not exists(select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID)
begin
	raiserror('Invalid customerID (%d) specified ',16,1,@CustID)
	return 1
end
if @SectorID is NULL OR @SectorID NOT IN (2,3,5)
begin
	raiserror('Invalid @SectorID specified',16,1)
	return 1
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_UpdateCustomerSector

BEGIN TRY  


	

	UPDATE Snoopy.tbl_Customers
	   SET [SectorID] = @SectorID
	 WHERE CustomerID = @CustID


	COMMIT TRANSACTION trn_UpdateCustomerSector

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateCustomerSector
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
