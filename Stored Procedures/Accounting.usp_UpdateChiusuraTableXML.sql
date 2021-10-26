SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_UpdateChiusuraTableXML] 
@UserAccessID				int,
@values						varchar(max),
@LifeCycleID				INT
/*@ChiusuraSnapshotID			INT,
@ConsegnaTransID			int,
@RipristinoTransID			int*/
AS


declare @ret INT,@ChiusuraSnapshotID INT


select @ChiusuraSnapshotID = LifeCycleSnapshotID 
FROM Accounting.tbl_Snapshots 
WHERE @LifeCycleID=LifeCycleID AND SnapshotTypeID = 3 --Chiusura

if @ChiusuraSnapshotID is null 
begin
	raiserror('Invalid @LifeCycleID specified or LifeCycle is not closed',16,1)
	return 1
END

set @ret = 0

--modifica direttamtne la Chiusura del tavolo
EXECUTE @ret = [Accounting].[usp_UpdateSnapshotXML] 
   @ChiusuraSnapshotID
  ,@values
  ,@UserAccessID


/* vecchio modo con ricalcolo dell Consegna e ripristino

if @ChiusuraSnapshotID is null
begin
	raiserror('NULL @ChiusuraSnapshotID specified',16,1)
	return 1
END

IF @values is NULL OR LEN(@values) = 0
begin
	raiserror('Must specify Chiusura values',16,1)
	return 1
end


declare @LifeCycleID int
select @LifeCycleID=LifeCycleID from Accounting.tbl_Snapshots where LifeCycleSnapshotID = @ChiusuraSnapshotID
if @LifeCycleID is null 
begin
	raiserror('Invalid @ChiusuraSnapshotID specified',16,1)
	return 1
END

if @ConsegnaTransID is null 
begin
	raiserror('NULL @ConsegnaTransID specified',16,1)
	return 1
END

if not exists (
select TransactionID 
from Accounting.tbl_Transactions 
where TransactionID = @ConsegnaTransID
--must be the Consegna of the specified Chiusura
and SourceLifeCycleID = @LifeCycleID
and OpTypeID = 6 --is a Consegna
)
begin
	raiserror('Invalid @ConsegnaTransID specified',16,1)
	return 1
END

if @RipristinoTransID is not null
and not exists (
	--make sure that the ripristino has been created by the same lifecycle that accepeted the Consegna
	select rip.TransactionID 
	from Accounting.tbl_Transactions rip
	inner join Accounting.tbl_LifeCycles ripSource on ripSource.LifeCycleID = rip.SourceLifeCycleID
	inner join Accounting.tbl_Transactions con on con.DestLifeCycleID = ripSource.LifeCycleID 
	where rip.TransactionID = @RipristinoTransID and con.TransactionID = @ConsegnaTransID
)
begin
	raiserror('Invalid @RipristinoTransID specified',16,1)
	return 1
END





BEGIN TRANSACTION trn_UpdateChiusuraTableXML

BEGIN TRY  

		declare @XML xml = @values



		--fill up the Consegna values string
		declare @conXML as varchar(max),@chiuXML varchar(max),@ripXML varchar(max),@DenoID int,@con int,@chiu int,@rip int,@exrate  varchar(8)
		
		set @conXML = '<ROOT>
		'
		set @chiuXML = '<ROOT>
		'
		set @ripXML = '<ROOT>
		'

		declare consegna_cursor cursor for
		select c.DenoID,
				(T.N.value('@qty', 'int') - [Accounting].[fn_StockCalculateConsegna] (
					[DenoID],
					T.N.value('@qty', 'int'),
					[InitialQty],
					[moduleValue],
					1
				) ) as Chiusura,
			[Accounting].[fn_StockCalculateConsegna] (
							c.[DenoID],
							T.N.value('@qty', 'int'),
							c.[InitialQty],
							c.[moduleValue],
							1
				)  as Consegna,
			[Accounting].[fn_TableCalculateRipristino](
							c.[DenoID],
							T.N.value('@qty', 'int'),
							c.[InitialQty],
							c.[moduleValue]
				)  as Ripristino,
				T.N.value('@exrate', 'varchar(8)') as exrate
			from [CasinoLayout].[vw_AllStockCompositions] c
			left outer join @XML.nodes('ROOT/DENO') as T(N) on T.N.value('@denoid', 'int') = c.DenoID
			where StockID = (select StockID from Accounting.LifeCycles where LifeCycleID = @LifeCycleID) and c.EndOfUseGamingDate is null


		Open consegna_cursor

		Fetch Next from consegna_cursor into @DenoID,@chiu,@con,@rip,@exrate
		While @@FETCH_STATUS = 0
		Begin

			if @con > 0
				set @conXML += '<DENO denoid="' + cast(@DenoID as varchar(16)) + '" qty="' + cast(@con as varchar(16))  + '" exrate="' + @exrate +'" CashInbound="0" />
		'
			if @chiu > 0
				set @chiuXML += '<DENO denoid="' + cast(@DenoID as varchar(16)) + '" qty="' + cast(@chiu as varchar(16))  + '" exrate="' + @exrate +'"/>
		'
			if @rip > 0
				set @ripXML += '<DENO denoid="' + cast(@DenoID as varchar(16)) + '" qty="' + cast(@rip as varchar(16))  + '" exrate="' + @exrate +'" CashInbound="1" />
		'
			Fetch Next from consegna_cursor into @DenoID,@chiu,@con,@rip,@exrate
		End

		close consegna_cursor
		deallocate consegna_cursor

		set @conXML += '</ROOT>'
		set @chiuXML += '</ROOT>'
		set @ripXML += '</ROOT>'

		print 'QUESTA E'' LA Consegna '
		print @conXML
		print '

		E QUESTA E'' LA Chiusura '
		print @chiuXML
		print '

		E QUESTO E'' IL RIPRISTINO'
		print @ripXML



		--go update Chiusura 
		execute [Accounting].[usp_UpdateSnapshotXML] @ChiusuraSnapshotID,@chiuXML,@UserAccessID	

		--go update Consegna 
		execute [Accounting].[usp_UpdateTransactionXML] @ConsegnaTransID,@conXML,@UserAccessID	

		if @RipristinoTransID is not null
		begin
			--go update Consegna 
			execute @ret = [Accounting].[usp_UpdateTransactionXML] @RipristinoTransID,@ripXML,@UserAccessID	
		end

	COMMIT TRANSACTION trn_UpdateChiusuraTableXML

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateChiusuraTableXML	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
*/
return @ret
GO
