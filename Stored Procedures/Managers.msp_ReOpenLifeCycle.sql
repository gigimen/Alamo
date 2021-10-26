SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_ReOpenLifeCycle] 
@lfid int
AS
declare @transID int
select @transID = TransactionID
from Accounting.vw_AllTransactions 
where SourceLifeCycleID = @lfid and OperationName = 'ConsegnaPerRipristino' 

--remove Consegna per ripristino
if @transID is not null
begin
	print 'Consegna transID: ' + str(@transID)
	
	--if Consegna has been accepted raise an error
	if exists( select TransactionID from Accounting.vw_AllTransactions 
			where TransactionID = @transID
			and DestLifeCycleID is not null)
	begin
		raiserror('Consegna per ripristino has been accepted already!!',16,1)
		--return (1)
	end 
	exec [Managers].[msp_DeleteTransaction] @transID
end

else
	print 'No Consegna'
--remove Chiusura
declare @ssID int
select @ssID = LifeCycleSnapshotID
from Accounting.vw_AllSnapshots 
where LifeCycleID = @lfid and FName = 'Chiusura'
if not @ssID is null
begin
	print 'Chiusura ssID: ' + str(@ssID)
	execute [Managers].[msp_DeleteSnapshot] @ssid

end
else print 'No Chiusura'
GO
