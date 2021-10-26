SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CreateRipristinoTables] 
@UserAccessID			int,
@MSLFID					INT,
@exrate					float,
@cCreated				int output
AS

if @MSLFID is null
begin
	raiserror('NULL @@MSLFID specified',16,1)
	return 1
END


if not exists (
select lf.LifeCycleID 
from Accounting.tbl_LifeCycles lf
inner join Accounting.tbl_Snapshots ap on ap.LifeCycleID = lf.LifeCycleID and ap.SnapshotTypeID = 1 and ap.LCSnapShotCancelID is null
left outer join Accounting.tbl_Snapshots ch on ch.LifeCycleID = lf.LifeCycleID and ch.SnapshotTypeID = 3 and ch.LCSnapShotCancelID is null
where lf.LifeCycleID = @MSLFID and lf.StockID = 31 and ch.LCSnapShotCancelID is null
)
begin
	raiserror('Invalid @@MSLFID specified',16,1)
	return 1
END

set @cCreated = 0;
--this table will return all ripristino transaction id created
declare @RipTrans TABLE (StockID int,Tag varchar(16),LifeCycleID int, RipTransID int,GamingDate datetime)



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateRipristinoTables

BEGIN TRY  


	--if we already have done the ripristion return all infos
	if not exists (SELECT [TransactionID] FROM [Accounting].[vw_AllPendingConsegnaFromTables])
	begin
			insert @RipTrans 
			select
				[StockID]
				,[Tag]
				,[LifeCycleID]
				,[RIPTransactionID]
				,GamingDate
			FROM [Accounting].[vw_AllChiusuraConsegnaRipristino]
			where RipSourceLifeCycleID = @MSLFID and StockTypeID = 1

			  --aggiorna anche il cambio euro dei gettoni euro

			UPDATE Accounting.tbl_TransactionValues
				SET [ExchangeRate] = @exrate
				from Accounting.tbl_TransactionValues t,@RipTrans r,CasinoLayout.tbl_Denominations d
				WHERE t.[TransactionID] = r.RipTransID and t.DenoID = d.DenoID and d.ValueTypeID = 36

	end
	else
	begin
		--do create all ripristinos

		--fill up the Consegna values string
		declare @consegnatransid int
				,@ripristiontransid int
				,@StockID int
				,@StockTypeID int
				,@lfid int
				,@AcceptTimeLoc datetime
				,@AcceptTimeUTC datetime
				,@GamingDate	datetime
				,@Tag varchar(16)



		declare consegna_cursor cursor for
		SELECT [TransactionID],SourceStockID,SourceStockTypeID,SourceLifeCycleID,SourceTag,SourceGamingDate
			FROM [Accounting].[vw_AllPendingConsegnaFromTables]


		Open consegna_cursor

		Fetch Next from consegna_cursor into @consegnatransid,@StockID,@StockTypeID,@lfid,@Tag,@GamingDate
		While @@FETCH_STATUS = 0  
		Begin

			--accept Consegna transaction
			EXECUTE [Accounting].[usp_AcceptTransaction] 
			   @consegnatransid
			  ,@MSLFID
			  ,@UserAccessID
			  ,null --@ConfUserID
			  ,null --@ConfUserGroupID
			  ,@AcceptTimeLoc OUTPUT
			  ,@AcceptTimeUTC OUTPUT

			--create ripristino transaction
			INSERT INTO Accounting.tbl_Transactions
				   ([OpTypeID]
				   ,[SourceLifeCycleID]
				   ,[DestStockID]
				   ,[SourceTime]
				   ,[DestStockTypeID]
				   ,[SourceUserAccessID])
 
			values(
					5,--@OpTypeID		,
					@MSLFID		,
					@StockID		,
					@AcceptTimeUTC		,
					@StockTypeID	,
					@UserAccessID		
					)

			set @ripristiontransid = @@IDENTITY

			insert into Accounting.tbl_TransactionValues 
			(
				TransactionID,
				DenoID,
				Quantity,
				ExchangeRate,
				CashInbound
			)
			--	values( @DenoID,@qty,@exchange,@CashInbound)
			select 
				@ripristiontransid ,
				c.DenoID,
				[Accounting].[fn_TableCalculateRipristino](
						c.[DenoID],
						isnull(ch.Chiusura,0)+isnull(ch.Consegna,0),
						c.[InitialQty],
						c.[ModuleValue]
					),
				@exrate,
				1 --rispristino is cashinbound
			from [CasinoLayout].[vw_AllStockCompositions] c
			left outer join [Accounting].[vw_AllChiusuraConsegnaDenominations] ch on ch.DenoID = c.DenoID and ch.StockID = c.StockID
			where ch.LifeCycleID = @lfid and 
				[Accounting].[fn_TableCalculateRipristino](
							c.[DenoID],
							isnull(ch.Chiusura,0)+isnull(ch.Consegna,0),
							c.[InitialQty],
							c.[ModuleValue]) > 0
			and c.EndOfUseGamingDate is null

	

			insert @RipTrans values(@StockID,@Tag,@lfid,@ripristiontransid,@GamingDate)

			Fetch Next from consegna_cursor into @consegnatransid,@StockID,@StockTypeID,@lfid,@Tag,@GamingDate
		End

		close consegna_cursor
		deallocate consegna_cursor


		select @cCreated = count(*) from @RipTrans

	end


	select * from @RipTrans

	COMMIT TRANSACTION trn_CreateRipristinoTables

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateRipristinoTables
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
