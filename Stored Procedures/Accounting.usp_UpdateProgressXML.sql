SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_UpdateProgressXML]
@lfCyID 		INT,
@values			VARCHAR(MAX),
@statetime		DATETIME OUTPUT,
@UserAccessID	INT
AS



--if not defined set to current time
IF @statetime IS NULL
	SET @statetime = GETUTCDATE()

IF NOT EXISTS ( SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses WHERE UserAccessID = @UserAccessID)
BEGIN
	RAISERROR('User access is invalid %d',16,-1,@UserAccessID)
	RETURN (1)
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_UpdateProgressXML

BEGIN TRY  

	/*
	'<ROOT>
	<DENO denoid="93" exrate="1.00" qty="34600" />
	<DENO denoid="93" exrate="1.00" qty="40500" />
	<DENO denoid="93" exrate="1.00" qty="41500" />
	<DENO denoid="93" exrate="1.00" qty="41000" />
	<DENO denoid="93" exrate="1.00" qty="42000" />
	<DENO denoid="93" exrate="1.00" qty="41000" />
	<DENO denoid="93" exrate="1.00" qty="51000" />
	<DENO denoid="93" exrate="1.00" qty="37000" />
	<DENO denoid="93" exrate="1.00" qty="47000" />
	<DENO denoid="93" exrate="1.00" qty="41100" /> 
	</ROOT>'
	*/


	declare @XML xml = @values

		select	n.DenoID,
				v.DenoID,
				n.[Quantity],
				v.[Quantity],
				n.[ExchangeRate],
				v.[ExchangeRate]
		from 
		(
			select 
			T.N.value('@denoid', 'int') as DenoID,
			cast(T.N.value('@qty', 'float') as Int) AS [Quantity],
			--T.N.value('@qty', 'int') as [Quantity],
			T.N.value('@exrate', 'float') as [ExchangeRate]
			from @XML.nodes('ROOT/DENO') as T(N)
		)n
		FULL OUTER JOIN 
		(
			SELECT 
				DenoID,
				[Quantity],
				[ExchangeRate]
			from Accounting.tbl_Progress t
			where StateTime = @statetime AND 
				LifeCycleID = @lfCyID
		) v ON n.DenoID = v.DenoID 
		where n.DenoID is not null



	declare progress_cursor cursor for
		select	n.DenoID,
				v.DenoID,
				n.[Quantity],
				v.[Quantity],
				n.[ExchangeRate],
				v.[ExchangeRate]
		from 
		(
			select 
			T.N.value('@denoid', 'int') as DenoID,
			cast(T.N.value('@qty', 'float') as Int) AS [Quantity],
			--T.N.value('@qty', 'int') as [Quantity],
			T.N.value('@exrate', 'float') as [ExchangeRate]
			from @XML.nodes('ROOT/DENO') as T(N)
		)n
		FULL OUTER JOIN 
		(
			SELECT 
				DenoID,
				[Quantity],
				[ExchangeRate]
			from Accounting.tbl_Progress t
			where StateTime = @statetime AND 
				LifeCycleID = @lfCyID
		) v ON n.DenoID = v.DenoID 
		where n.DenoID is not null


	DECLARE @DenoID int,@OldDenoid int,@qty int,@oldQty int,@exrate float,@oldExRate FLOAT


	Open progress_cursor
	Fetch Next from progress_cursor into @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate 
	While @@FETCH_STATUS = 0 
	Begin
		--use the existing DenoID
		--select  @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate 
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
		if @qty <> @oldQty OR @OldDenoid IS null
		BEGIN
			if @OldDenoid is null
			begin
				INSERT INTO Accounting.tbl_Progress 
					(LifeCycleID,DenoID,Quantity,ExchangeRate,StateTime,UserAccessID) 
					VALUES(
						@lfCyID,
						@DenoID,
						@qty,
						@exrate,
						@statetime,
						@UserAccessID
						)

				print 'DenoID ' + cast(@DenoID as varchar(32)) + ' ' + cast(@statetime as varchar(32)) + ' value added'		
			end
			else --this is a real update of an existing one
			begin
				UPDATE Accounting.tbl_Progress 
					SET Quantity = @qty,
					ExchangeRate = @exrate,
					UserAccessID = @UserAccessID
					WHERE 
					DenoID=@DenoID AND 
					StateTime = @statetime AND 
					LifeCycleID = @lfCyID


				--enter also a modification record in ProgressModificationTable

				INSERT INTO FloorActivity.tbl_ProgressModifications
					([UserAccessID]
					,[LifeCycleID]
					,[DenoID]
					,[StateTime]
					,[FromQuantity]
					,[ToQuantity]
					,[ExchangeRate])
				VALUES
					(@UserAccessID
					,@lfCyID
					,@DenoID
					,@statetime
					,@oldQty
					,@qty
					,@OldExrate)

			end
		end
		Fetch Next from progress_cursor into @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate
	End

	close progress_cursor
	deallocate progress_cursor

	COMMIT TRANSACTION trn_UpdateProgressXML

	SET @statetime = GeneralPurpose.fn_UTCToLocal(1,@statetime)

END TRY  
BEGIN CATCH  

	ROLLBACK TRANSACTION trn_UpdateProgressXML		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH
RETURN @ret
GO
