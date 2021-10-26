SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [Managers].[msp_RemoveLifeCycle] 
@lfid int
AS
--if Consegna has been accepted raise an error
if exists( select TransactionID from Accounting.vw_AllTransactions 
		where SourceLifeCycleID = @lfid
		and OperationName = 'ConsegnaPerRipristino'
		and DestLifeCycleID is not null)
begin
	raiserror('Consegna per ripristino has been accepted already!!',16,1)
	--return (1)
end 
--if the lifecycle accepted some transaction and the
--source is now closed raise an error (except for Ripristino)
if exists (select TransactionID 
	from Accounting.vw_AllTransactions 
	inner join Accounting.tbl_Snapshots
	on Accounting.vw_AllTransactions.SourceLifeCycleID = Accounting.tbl_Snapshots.LifeCycleID
	and Accounting.tbl_Snapshots.SnapshotTypeID = 3
	where Accounting.vw_AllTransactions.DestLifeCycleID = @lfid
	and Accounting.vw_AllTransactions.OperationName <> 'Ripristino'
)
begin
	raiserror('Transaction exist that has been accepted already and the source stock is closed now!!',16,1)
	--return (2)
end 
	
--first reopen lifecycle
exec [Managers].[msp_ReOpenLifeCycle] @lfid
	
	
--remove all transactions for which @lfid is the source
--or the destination (execept for ripristino)
declare @ret int
set @ret = CURSOR_STATUS ('global','trans_cursor')
if @ret > -3
begin
	print 'deallocting trans_cursor'
	DEALLOCATE trans_cursor
end
declare @transid int
DECLARE trans_cursor CURSOR
   FOR select TransactionID 
	from Accounting.vw_AllTransactions 
	where SourceLifeCycleID = @lfid
	or (DestLifeCycleID = @lfid
		and Accounting.vw_AllTransactions.OperationName <> 'Ripristino')
OPEN trans_cursor
FETCH NEXT FROM trans_cursor INTO @transid
WHILE (@@FETCH_STATUS <> -1)
BEGIN
   exec @ret = [Managers].[msp_DeleteTransaction] @transid
   FETCH NEXT FROM trans_cursor INTO @transid
END
set @ret = CURSOR_STATUS ('global','trans_cursor')
if @ret > -3
begin
	print 'deallocting trans_cursor'
	DEALLOCATE trans_cursor
end
	
--remove all customer transactions for which @lfid is the source
set @ret = CURSOR_STATUS ('global','custtrans_cursor')
if @ret > -3
begin
	--print 'deallocting custtrans_cursor'
	DEALLOCATE custtrans_cursor
end


--remove all credit card transactions
print 'remove all Credit Card trasaction'
delete from Snoopy.tbl_CartediCredito
where FK_CustomerTransactionID in (select CustomerTransactionID from Snoopy.tbl_CustomerTransactions where SourceLifeCycleID = @lfid)

print 'delete all customer transactions'
DECLARE custtrans_cursor CURSOR
   FOR select CustomerTransactionID 
	from Snoopy.tbl_CustomerTransactions 
	where SourceLifeCycleID = @lfid
OPEN custtrans_cursor
FETCH NEXT FROM custtrans_cursor INTO @transid
WHILE (@@FETCH_STATUS <> -1)
BEGIN
   exec @ret = [Managers].[msp_DeleteCustTransaction] @transid
   FETCH NEXT FROM custtrans_cursor INTO @transid
END
set @ret = CURSOR_STATUS ('global','custtrans_cursor')
if @ret > -3
begin
	--print 'deallocting custtrans_cursor'
	DEALLOCATE custtrans_cursor
end

--remove all snapshots execept apertura
declare @ssid int
set @ret = CURSOR_STATUS ('global','ss_cursor')
if @ret > -3
begin
	print 'deallocting ss_cursor'
	DEALLOCATE ss_cursor
end
DECLARE ss_cursor CURSOR
   FOR select LifeCycleSnapshotID 
	from Accounting.vw_AllSnapshots 
	where LifeCycleID = @lfid
		and SnapshotTypeID <> 1--'Apertura'
OPEN ss_cursor
FETCH NEXT FROM ss_cursor INTO @ssid
WHILE (@@FETCH_STATUS <> -1)
BEGIN
   exec @ret = [Managers].[msp_DeleteSnapshot] @ssid
   FETCH NEXT FROM ss_cursor INTO @ssid
END
set @ret = CURSOR_STATUS ('global','ss_cursor')
if @ret > -3
begin
	print 'deallocting ss_cursor'
	DEALLOCATE ss_cursor
end

--remove all lifecycle progress
print 'remove all lifecycle progress'
DELETE FROM FloorActivity.tbl_ProgressModifications WHERE LifeCycleID = @lfid
delete from Accounting.tbl_Progress where LifeCycleID = @lfid

--remove all lifecycle progress
print 'remove all eurotransactions'
update Accounting.tbl_EuroTransactions set RedeemTransactionID = null 
where RedeemTransactionID in (select TransactionID from Accounting.tbl_EuroTransactions where LifeCycleID = @lfid)
delete from Accounting.tbl_EuroTransactions where LifeCycleID = @lfid

--remove all chaslesstransactions
print 'remove all cashless trasaction'
delete from Accounting.tbl_CashlessTransactions where LifeCycleID = @lfid

--remove all tickettransactions
print 'remove all ticket trasaction'
delete from Accounting.tbl_TicketTransactions where LifeCycleID = @lfid


--remove apertura
select @ssid = LifeCycleSnapshotID 
	from Accounting.vw_AllSnapshots 
	where LifeCycleID = @lfid
		and Accounting.vw_AllSnapshots.FName = 'Apertura'
if @ssid is not null
begin
	print 'removing apertura: ' + str(@ssid)
   	exec @ret = [Managers].[msp_DeleteSnapshot] @ssid
end
else
	print 'No apertura'

--get ripristino trans id
select @transid = TransactionID 
	from Accounting.vw_AllTransactions 
	where DestLifeCycleID = @lfid
		and Accounting.vw_AllTransactions.OperationName = 'Ripristino'
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
else
	print 'No ripristino'

print 'remove all registrations'
DELETE FROM Snoopy.tbl_Registrations 
WHERE UserAccessID IN(SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses WHERE LifeCycleID = @lfid)


print 'deleting user accesses for LifeCycleID: ' + str(@lfid)
DELETE FROM FloorActivity.tbl_UserAccesses WHERE LifeCycleID = @lfid


PRINT 'deleting LifeCycleID: ' + str(@lfid)
delete from Accounting.tbl_LifeCycles where LifeCycleID = @lfid
GO
