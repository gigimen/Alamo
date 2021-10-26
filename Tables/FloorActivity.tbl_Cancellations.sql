CREATE TABLE [FloorActivity].[tbl_Cancellations]
(
[CancelID] [int] NOT NULL IDENTITY(1, 1),
[CancelDate] [datetime] NOT NULL,
[UserAccessID] [int] NOT NULL,
[CancelDateLoc] [datetime] NOT NULL CONSTRAINT [DF_CancelActions_CancelDateLoc] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_Cancellations] ADD CONSTRAINT [PK_TransactionCanceled] PRIMARY KEY CLUSTERED  ([CancelID]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_Cancellations] WITH NOCHECK ADD CONSTRAINT [FK_TransactionCanceled_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
GRANT INSERT ON  [FloorActivity].[tbl_Cancellations] TO [CKeyUsage]
GO
GRANT SELECT ON  [FloorActivity].[tbl_Cancellations] TO [CKeyUsage]
GO
