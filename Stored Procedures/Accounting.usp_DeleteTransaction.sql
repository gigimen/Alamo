SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_DeleteTransaction]
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
	select TransactionID from Accounting.tbl_Transactions 
		where TransactionID = @transID
		and Accounting.tbl_Transactions.TrCancelID is null
	)
begin
	raiserror('Invalid TransactionID (%d) specified or already cancelled',16,1,@transID)
	return 1
END


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteTransaction

BEGIN TRY  


	--first create a new TransactionCancelID 
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)

	declare @cancID int
	set @cancID = SCOPE_IDENTITY()
	--update the transaction
	update Accounting.tbl_Transactions
		set Accounting.tbl_Transactions.TrCancelID = @cancID
		where TransactionID = @transID



	declare @attr varchar(256)
	select @attr = 'TransID=''' + cast(TransactionID as varchar(16)) + ''' OpTypeID=''' + cast(OpTypeID as varchar(16)) + ''''
	FROM Accounting.tbl_Transactions
	where TransactionID = @transID
	execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteTransaction',@attr


	COMMIT TRANSACTION trn_DeleteTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteTransaction
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret	
GO
