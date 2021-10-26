SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_AcceptTransaction]
@transID int,
@LifeCycleID int,
@UserAccessID int,
@ConfUserID int,
@ConfUserGroupID int,
@AcceptTimeLoc datetime output,
@AcceptTimeUTC datetime output
AS

if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID= @UserAccessID) 
begin
	raiserror('Must specify a valid UserAccessID',16,-1)
	return (1)
END

if (@LifeCycleID is not null) 
BEGIN


	if ( 
	@LifeCycleID < 0 
	or not exists(select LifeCycleID from Accounting.tbl_LifeCycles where  LifeCycleID = @LifeCycleID)
	)
	begin
		raiserror('Must specify a valid LifeCycleID',16,-1)
		return (1)
	END

	--transaction must be not accepted yet or accpepted already by me
	IF EXISTS (SELECT TransactionID from Accounting.vw_AllTransactions
				 where TransactionID = @transID
				 and DestLifeCycleID is NOT NULL --transaction has been already accepted!
				 AND DestLifeCycleID <> @LifeCycleID --accepted by som other LifeCycleID!!!
		)
	BEGIN
		raiserror('Transaction already accepted!!',16,-1)
		return (1)
    END
        
END


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_AcceptTransaction

BEGIN TRY  



	if (@LifeCycleID is not null)
	begin
		declare @StockID int
		declare @StockTypeID int
		select 	@StockID = Accounting.tbl_LifeCycles.StockID,
			@StockTypeID = CasinoLayout.Stocks.StockTypeID
			from Accounting.tbl_LifeCycles
			inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = Accounting.tbl_LifeCycles.StockID 
			where Accounting.tbl_LifeCycles.LifeCycleID = @LifeCycleID

		set @AcceptTimeUTC = GetUTCDate()
		update Accounting.tbl_Transactions
			set DestLifeCycleID 	= @LifeCycleID,
			DestStockTypeID 		= @StockTypeID,
			DestStockID				= @StockID,
			DestUserAccessID 		= @UserAccessID,
			DestTime				= @AcceptTimeUTC
			where TransactionID 	= @transID

		set @AcceptTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@AcceptTimeUTC)

	end
	else --just mark the useraccess id 
	begin
		update Accounting.tbl_Transactions
			set DestUserAccessID 	= @UserAccessID
			where TransactionID 	= @transID
	end

	--if a valid confirmation is specified insert an entry into confirmation table
	if	(@ConfUserID is not null and @ConfUserGroupID is not null )
	begin
		if exists (select UserID from CasinoLayout.Users where UserID = @ConfUserID) 
		   and exists (select UserGroupID from CasinoLayout.UserGroups where UserGroupID = @ConfUserGroupID) 
		begin
			--since it is an accept insert 0 in field IsSourceConfirmation
			insert into Accounting.tbl_Transaction_Confirmations 
				(TransactionID,UserID,UserGroupID,IsSourceConfirmation) 
				select TransactionID,@ConfUserID,@ConfUserGroupID,0 from Accounting.tbl_Transactions 
					where TransactionID 	= @transID
		end
	end

COMMIT TRANSACTION trn_AcceptTransaction

END TRY  
BEGIN CATCH  
	DECLARE @err INT
	ROLLBACK TRANSACTION trn_AcceptTransaction		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH


return @ret
GO
