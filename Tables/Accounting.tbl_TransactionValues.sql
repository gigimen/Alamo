CREATE TABLE [Accounting].[tbl_TransactionValues]
(
[DenoID] [int] NOT NULL,
[TransactionID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL,
[CashInbound] [bit] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [Accounting].[NoDelForAcceptedTrans] ON [Accounting].[tbl_TransactionValues] 
INSTEAD OF DELETE 
AS
declare @transid int
declare @denoid INT
DECLARE @CashInbound bit
--delete all transactionvalues in the request
declare @ret int
set @ret = CURSOR_STATUS ('global','transval_cursor')
if @ret > -3
begin
	DEALLOCATE transval_cursor
end

DECLARE transval_cursor CURSOR
 	FOR select TransactionID,DenoID,CashInbound from deleted
OPEN transval_cursor
FETCH NEXT FROM transval_cursor INTO @transid,@denoid,@CashInbound
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	if GeneralPurpose.fn_GetAlamoVersion() > 1
	begin
		if exists (select TransactionID from Accounting.tbl_Transactions where TransactionID = @transid and DestUserAccessID is not null )
		begin
			raiserror('Cannot modify an accepted transaction',16,1)
			return
		end
	end
	DELETE from Accounting.tbl_TransactionValues
	    WHERE TransactionID = @transid 
		and DenoID = @denoid   
		AND CashInbound = @CashInbound
	FETCH NEXT FROM transval_cursor INTO @transid,@denoid,@CashInbound
END

set @ret = CURSOR_STATUS ('global','transval_cursor')
if @ret > -3
begin
	DEALLOCATE transval_cursor
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Accounting].[NoInsForAcceptedTrans] ON [Accounting].[tbl_TransactionValues] 
INSTEAD OF INSERT 
AS
declare @transid int
select @transid = TransactionID  from inserted
if GeneralPurpose.fn_GetAlamoVersion() > 1
begin
	if exists (select TransactionID from Accounting.tbl_Transactions where TransactionID = @transid and DestUserAccessID is not null )
	begin
		raiserror('Cannot add values to an accepted transaction',16,1)
		return
	end
end
INSERT INTO Accounting.tbl_TransactionValues
    (TransactionID,Quantity,DenoID,ExchangeRate,CashInbound)
    select @transid,Quantity,DenoID,ExchangeRate,CashInbound from inserted

GO
DISABLE TRIGGER [Accounting].[NoInsForAcceptedTrans] ON [Accounting].[tbl_TransactionValues]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Accounting].[NoModForAcceptedTrans] ON [Accounting].[tbl_TransactionValues] 
INSTEAD OF UPDATE 
AS
declare @transid int
declare @denoid int
declare @qty INT
DECLARE @CashInbound bit
declare @exchange float
select 	@transid 	= TransactionID,
	@denoid 	= DenoID,
	@exchange	= ExchangeRate,
	@qty 		= Quantity,
	@CashInbound = CashInbound
	from inserted
if GeneralPurpose.fn_GetAlamoVersion() > 1
begin
	if exists (select TransactionID from Accounting.tbl_Transactions where TransactionID = @transid and DestUserAccessID is not null )
	begin
		raiserror('Cannot modify an accepted transaction',16,1)
		return
	end
end
UPDATE Accounting.tbl_TransactionValues
    SET Quantity 	= @qty,
	ExchangeRate 			= @exchange
    WHERE TransactionID = @transid 	
	and DenoID = @denoid
	AND CashInbound = @CashInbound

GO
DISABLE TRIGGER [Accounting].[NoModForAcceptedTrans] ON [Accounting].[tbl_TransactionValues]
GO
ALTER TABLE [Accounting].[tbl_TransactionValues] ADD CONSTRAINT [PK_Values] PRIMARY KEY CLUSTERED  ([DenoID], [TransactionID], [CashInbound]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TrancastionValue_ByTransactionID] ON [Accounting].[tbl_TransactionValues] ([TransactionID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_TransactionValues] ADD CONSTRAINT [FK_TransactionValues_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [Accounting].[tbl_TransactionValues] WITH NOCHECK ADD CONSTRAINT [FK_TransactionValues_Transactions] FOREIGN KEY ([TransactionID]) REFERENCES [Accounting].[tbl_Transactions] ([TransactionID])
GO
