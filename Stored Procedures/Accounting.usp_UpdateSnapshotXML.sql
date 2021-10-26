SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_UpdateSnapshotXML]
@LFSSID			INT,
@values			VARCHAR(max),
@UAID			INT	
AS

IF NOT EXISTS (select LifeCycleSnapshotID from Accounting.tbl_Snapshots where LifeCycleSnapshotID = @LFSSID  )
BEGIN
	RAISERROR('Unexisting LifeCycleSnapshotID (%d) specified',16,1,@LFSSID)
	RETURN 1
END

/*
set @values = '<ROOT>
<DENO denoid="1" qty="0" exrate="1.58"/>
<DENO denoid="2" qty="4" exrate="1.58"/>
<DENO denoid="3" qty="123" exrate="1.58"/>
</ROOT>'
*/



declare 
@DenoID int,
@OldDenoid int,
@qty int,
@oldQty INT ,
@exrate	float,
@oldExRate float

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_UpdateSnapshotXML

BEGIN TRY  
	
	declare @XML xml = @values

	--update only transaction values
	declare exclu_cursor cursor for
		select	n.DenoID,
				v.DenoID,
				n.[Quantity],
				v.[Quantity],
				n.[ExchangeRate],
				v.[ExchangeRate]
		from 
		(
			SELECT 
				T.N.value('@denoid', 'int') AS DenoID,
				cast(T.N.value('@qty', 'float') as int) AS [Quantity],
				T.N.value('@exrate', 'float') AS [ExchangeRate]
			from @XML.nodes('ROOT/DENO') as T(N)
		)n
		FULL OUTER JOIN 
		(
			SELECT 
				DenoID,
				[Quantity],
				[ExchangeRate]
			from Accounting.tbl_SnapshotValues t
			where LifeCycleSnapshotID = @LFSSID 
		) v ON n.DenoID = v.DenoID
		WHERE NOT (v.DenoID IS NULL AND n.[Quantity] = 0) AND NOT (n.[Quantity] is not null and v.[Quantity] is not null and n.[Quantity] = v.[Quantity]) 
	Open exclu_cursor

	Fetch Next from exclu_cursor into @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate
	While @@FETCH_STATUS = 0 
	Begin
		--use the existing DenoID
	
		if @oldQty is null 
		begin
			set @oldQty = 0
			set @OldExrate = @exrate  
		end		
	
		if @qty is null
		begin
			set @qty = 0
		end		
		--if both old and new are different than we have to apply the change
		if @qty <> @oldQty
		BEGIN
			--is it an update or a delete?
			IF @qty <> 0  
			begin
					if @OldDenoid is null
					begin
						--it is a new Denomination in the set
						INSERT into Accounting.tbl_SnapshotValues (LifeCycleSnapshotID,DenoID,Quantity,ExchangeRate)
						VALUES(@LFSSID , @DenoID,@qty,@exrate)
						print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value added'		
					end
					else --this is a real update of an existing one
					begin
						--update to new value
						update Accounting.tbl_SnapshotValues 
						set Quantity = @qty,
							ExchangeRate = @exrate
						where LifeCycleSnapshotID = @LFSSID and DenoID = @DenoID
						
						print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value updated'		
					end
			end 
			else
			begin--delete the value that now is 0
				if @DenoID is null
				begin
					set @DenoID = @olddenoid
				end	
			
				delete from Accounting.tbl_SnapshotValues 
				where LifeCycleSnapshotID = @LFSSID and DenoID = @DenoID
				
				print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value deleted'		
			END


			--insert a new entry in [FloorActivity].[SnapshotModifications] to record the change of value
			INSERT INTO FloorActivity.tbl_SnapshotModifications
						([UserAccessID]
						,[LifeCycleSnapshotID]
						,[DenoID]
						,[FromQuantity]
						,[ToQuantity]
						,[ExchangeRate])
			VALUES
						(@UAID,
						@LFSSID,
						@DenoID,
						@oldQty,
						@qty,
						@OldExrate)

		end
		Fetch Next from exclu_cursor into @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate 
	End

	close exclu_cursor
	deallocate exclu_cursor

	COMMIT TRANSACTION trn_UpdateSnapshotXML

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateSnapshotXML	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
