SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE procedure [Snoopy].[usp_DeleteBonifico]
@BonificoID int,
@UserAccessID int
AS


--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specified',16,1,@UserAccessID)
	return 1
end

if not exists (select BonificoID from Snoopy.tbl_Bonifici where BonificoID = @BonificoID)
begin
	raiserror('Invalid BonificoID (%d) specified',16,1,@BonificoID)
	return 2
end


declare @CustTransID INT

select @CustTransID = OrderCustTransID 
		from Snoopy.tbl_Bonifici 
		where BonificoID = @BonificoID

if @CustTransID is null
begin
	raiserror('Wrong Bonifico %d specified',16,1,@BonificoID)
	return 1
end



DECLARE @RC int

EXECUTE @RC = [Snoopy].[usp_DeleteCustomerTransaction] @CustTransID,@UserAccessID

return @RC
GO
