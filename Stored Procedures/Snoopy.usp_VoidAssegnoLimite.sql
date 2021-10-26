SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Snoopy].[usp_VoidAssegnoLimite]
@CustID int
AS
--first some check on parameters
if not exists(select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID)
begin
	raiserror('Invalid customerID (%d) specified ',16,1,@CustID)
	return 1
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_VoidAssegnoLimite

BEGIN TRY  



if exists (select CustomerId from Snoopy.tbl_AssegniLimite where CustomerID = @CustID)
begin

	UPDATE Snoopy.tbl_AssegniLimite
	SET [Limite] = 0
      ,[Nota] = 'c'
	where CustomerID = @CustID

end
else
begin
	INSERT INTO Snoopy.tbl_AssegniLimite
           ([CustomerId]
           ,[Limite]
           ,[Nota])
     VALUES
           (@CustID
           ,0
           ,'c')

end


	COMMIT TRANSACTION trn_VoidAssegnoLimite

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_VoidAssegnoLimite
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
