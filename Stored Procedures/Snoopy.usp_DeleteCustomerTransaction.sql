SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Snoopy].[usp_DeleteCustomerTransaction]
@transID int,
@UserAccessID int
AS




--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	return 1
END


if not exists 
	(
	select CustomerTransactionID from Snoopy.tbl_CustomerTransactions 
		where CustomerTransactionID = @transID
		and Snoopy.tbl_CustomerTransactions.CustTrCancelID is null
	)
begin
	raiserror('Invalid CustomerTransactionID (%d) specified',16,1,@transID)
	return 1
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteCustomerTransaction

BEGIN TRY  

	--first create a new CustTrCancelID 
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)

	declare @cancID int
	set @cancID = SCOPE_IDENTITY()

	update Snoopy.tbl_CustomerTransactions
		set CustTrCancelID = @cancID
		where CustomerTransactionID = @transID
	
	COMMIT TRANSACTION trn_DeleteCustomerTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteCustomerTransaction
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret	
END CATCH

declare @attr varchar(256)
select @attr = 'TransID=''' + cast(CustomerTransactionID as varchar(16)) + ''' OpTypeID=''' + cast(OpTypeID as varchar(16)) + ''''
FROM Snoopy.tbl_CustomerTransactions 
where CustomerTransactionID = @transID
execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteCustTransaction',@attr

return @ret
GO
