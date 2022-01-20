SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [Accounting].[usp_ReOpenLifeCycle]
@LifeCycleID int,
@UserAccessID int,
@apTimeLoc datetime output,
@apTimeUTC datetime output,
@lastLFID int OUTPUT,
@apSSID INT output

AS

declare @LCSSID int
select @LCSSID = LifeCycleSnapshotID 
	from Accounting.tbl_Snapshots 
	where LifeCycleID = @LifeCycleID 
	AND SnapshotTypeID = 3 --Chiusura
	and LCSnapShotCancelID is null
if @LCSSID is null
begin
	raiserror('Must specify a valid and closed lifecycle id',16,1)
	return (1)
end

declare @StockID INT

SELECT
	@apSSID = ss.LifecycleSnapshotID,
	@StockID = ss.StockID, 
	@apTimeLoc = ss.SnapshotTimeLoc,
	@apTimeUTC = ss.SnapshotTimeUTC
from Accounting.tbl_LifeCycles lf
inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots ss 
on ss.LifeCycleID = @LifeCycleID and ss.SnapshotTypeID = 1 --apertura 
where lf.LifeCycleID = @LifeCycleID
if @apSSID is null
begin
	raiserror('Must specify a valid and opened lifecycle id',16,1)
	return (1)
end


--check id a Consegna exists
declare @consegnaID int
select @consegnaID = TransactionID
from Accounting.vw_AllTransactions 
where SourceLifeCycleID = @LifeCycleID and OpTypeID = 6 --'ConsegnaPerRipristino' 

--make sure Consegna per ripristino has not been accepted already
if @consegnaID is not null
begin
	print 'Consegna TransID: ' + str(@consegnaID)
	
	--if Consegna has been accepted raise an error
	if exists(select TransactionID from Accounting.vw_AllTransactions 
			WHERE TransactionID = @consegnaID
			and DestLifeCycleID is not null)
	begin
		raiserror('Consegna per ripristino has been accepted already!!',16,1)
		return (1)
	end 
END
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ReOpenLifeCycle

BEGIN TRY  



	--NOW we can proceed with cancel action
	--first create a new CancelID
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)

	declare @cancID int
	set @cancID = SCOPE_IDENTITY()

	--update the Chiusura snapshot to be canceld
	update Accounting.tbl_Snapshots 
	set Accounting.tbl_Snapshots.LCSnapShotCancelID = @cancID
	where LifeCycleSnapshotID = @LCSSID

	--remove Consegna per ripristino
	if @consegnaID is not null
	begin
		update Accounting.tbl_Transactions 
		set Accounting.tbl_Transactions.TrCancelID = @cancID
		where Accounting.tbl_Transactions.TransactionID = @consegnaID
		--print 'Consegna TransID: ' + str(@consegnaID) + ' has been canceled'
	end



	--go and get the last Chiusura before this apertura
	select @lastLFID = LifeCycleID
	from Accounting.tbl_LifeCycles lf
	inner join (
		select max(GamingDate) as LastCloseGamingDate 
		from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
		where SS.SnapshotTypeID = 3 --Chiusura snapshottype
		and (SS.StockID =@StockID)  
	) as LCSS
	on lf.StockID = @StockID and  lf.GamingDate = LCSS.LastCloseGamingDate



	COMMIT TRANSACTION trn_ReOpenLifeCycle

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ReOpenLifeCycle
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
