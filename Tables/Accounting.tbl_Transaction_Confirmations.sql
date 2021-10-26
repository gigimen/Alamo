CREATE TABLE [Accounting].[tbl_Transaction_Confirmations]
(
[TransactionID] [int] NOT NULL,
[UserID] [int] NOT NULL,
[IsSourceConfirmation] [tinyint] NOT NULL,
[UserGroupID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [Accounting].[NotSameUserID] ON [Accounting].[tbl_Transaction_Confirmations] 
INSTEAD OF  INSERT
AS
	declare @UserAccess as int
	declare @TransID as int
	declare @InsertUserID as int
	declare @TransUserID as int
	select 	@TransID = TransactionID,
		@InsertUserID = UserID
	 from inserted
	-- Check if confirmation is for source or dest
	if exists (select IsSourceConfirmation from inserted where IsSourceConfirmation = 1)
	begin	-- for source
		select @UserAccess = SourceUserAccessID
			from Accounting.tbl_Transactions
			where @TransID = Accounting.tbl_Transactions.TransactionID
		--print ('IsSource')
		--print (@UserAccess)
	end
	
	else
	begin	-- for dest
		select @UserAccess = DestUserAccessID
			from Accounting.tbl_Transactions
			where @TransID = Accounting.tbl_Transactions.TransactionID
		--print ('IsDest')
		--print (@UserAccess)
	end
	
	select @TransUserID = UserID 
		from FloorActivity.tbl_UserAccesses
		where UserAccessID = @UserAccess
--	print(@TransUserID)
	if (@TransUserID = @InsertUserID)
	begin
		raiserror('User %d has already confirmaed',16,-1,@TransUserID)
		return
	end
	INSERT INTO Accounting.tbl_Transaction_Confirmations 
	       SELECT 	TransactionID,
			UserID,
			IsSourceConfirmation,
			UserGroupID
	       FROM inserted


GO
DISABLE TRIGGER [Accounting].[NotSameUserID] ON [Accounting].[tbl_Transaction_Confirmations]
GO
ALTER TABLE [Accounting].[tbl_Transaction_Confirmations] ADD CONSTRAINT [PK_Trans_Confirmations] PRIMARY KEY CLUSTERED  ([TransactionID], [UserID], [IsSourceConfirmation]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Transaction_Confirmations] ADD CONSTRAINT [FK_Trans_Confirmations_Transactions] FOREIGN KEY ([TransactionID]) REFERENCES [Accounting].[tbl_Transactions] ([TransactionID])
GO
ALTER TABLE [Accounting].[tbl_Transaction_Confirmations] WITH NOCHECK ADD CONSTRAINT [FK_Trans_Confirmations_UserGroups] FOREIGN KEY ([UserGroupID]) REFERENCES [CasinoLayout].[UserGroups] ([UserGroupID])
GO
ALTER TABLE [Accounting].[tbl_Transaction_Confirmations] ADD CONSTRAINT [FK_Trans_Confirmations_Users] FOREIGN KEY ([UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
