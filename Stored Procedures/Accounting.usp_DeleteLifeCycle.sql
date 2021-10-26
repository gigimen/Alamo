SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*
	Deletes a Life cycle by setting the field 
*/
CREATE procedure [Accounting].[usp_DeleteLifeCycle]
@LifeCycleID int,
@UserAccessID int
AS




--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	return 1
end

declare @StockID INT
declare @StockTypeID int
declare @Tag varchar(32)

select 	@StockID = Accounting.tbl_LifeCycles.StockID,
	@StockTypeID= CasinoLayout.Stocks.StockTypeID,
	@Tag = CasinoLayout.Stocks.Tag 
from Accounting.tbl_LifeCycles
inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = Accounting.tbl_LifeCycles.StockID
where LifeCycleID = @LifeCycleID


declare @LCSSID int
select @LCSSID = LifeCycleSnapshotID 
	from Accounting.tbl_Snapshots 
	where LifeCycleID = @LifeCycleID 
	AND SnapshotTypeID in 
		(select SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Apertura')

if @LCSSID is null
begin	
	raiserror('Invalid Lifecycle (%d) specified. Life cycle never opened!!!',16,1,@LifeCycleID)
	return (1)
END

--get ripristino trans id
declare @transid int
select @transid = TransactionID 
from Accounting.vw_AllTransactions 
where DestLifeCycleID = @LifeCycleID and OperationName = 'Ripristino'



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteLifeCycle

BEGIN TRY  




	if @transid is not null
	begin
		print 'Unaccepting ripristino: ' + str(@transid)
	
		--reset ripristino to unaccepted
		update Accounting.tbl_Transactions
			set DestTime = null,
			DestLifeCycleID = null,
			DestUserAccessID = null
			where TransactionID = @transid
			
		--remove also confirmation of ripristino acceptance
		delete from Accounting.tbl_Transaction_Confirmations 
			where TransactionID = @transid
			and IsSourceConfirmation = 0
		
	end
	/*
	else
	begin
		print 'No ripristino'
	end
	*/


	declare @timestampUTC datetime
	set @timestampUTC = GetUTCDate()
	
	--first create a new LifecycleSnapshotcancel
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(@timestampUTC,@UserAccessID)
		
		
	declare @cancID int
	set @cancID = @@IDENTITY
	
	--get rid of all lifecycleprogress inserted
	Delete from Accounting.tbl_Progress
	where LifeCycleID = @LifeCycleID

	--delete the Chiusura snapshot
	update Accounting.tbl_Snapshots 
	set Accounting.tbl_Snapshots.LCSnapShotCancelID = @cancID
	where LifeCycleSnapshotID = @LCSSID


	
	--broadcast a Chiusura message
	/*<ALAMO version='1'><MESS type='Chiusura' 
		LifeCycleID='114729' 
		LastLifeCycleID='-1' 
		StockID='16' 
		StockTypeID='1' 
		GamingDate='41168.0000' 
		SnapTimeLoc='41169.3543' 
		SnapTimeUTC='41169.2710' 
		Tag='AR17' 
		Value='0.00' 
		Drop='0.00' 
		UserID='2' 
		UserName='AlamoAlfa' /></ALAMO>
	*/
	declare @attribs varchar(1024)
	select @attribs = 
		'LifeCycleID=''' + CAST(@LifeCycleID as varchar(32)) + 
		''' LastLifeCycleID=''' + CAST(lf.LifeCycleID as varchar(32)) + 
		''' StockID=''' + CAST(@StockID as varchar(32))  + 
		''' StockTypeID=''' + CAST(@StockTypeID as varchar(32)) +
		''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](lf.GamingDate) + 
		''' SnapTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@timestampUTC) + 
		''' SnapTimeUTC=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@timestampUTC) + 
		''' Tag=''' + @Tag +
		''' Value=''0.00'' Drop=''0.00'' UserID=''2'' UserName=''AlamoAlfa'''
	from Accounting.tbl_LifeCycles lf
	--return last known LifeCycleID
	where lf.StockID = @StockID and lf.LifeCycleID < @LifeCycleID
	execute [GeneralPurpose].[usp_BroadcastMessage] 'Chiusura',@attribs


	COMMIT TRANSACTION trn_DeleteLifeCycle

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteLifeCycle		
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH

return @ret
GO
