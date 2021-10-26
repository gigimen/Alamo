CREATE TABLE [FloorActivity].[tbl_ProgressModifications]
(
[ModID] [int] NOT NULL IDENTITY(1, 1),
[UserAccessID] [int] NOT NULL,
[ModDate] [datetime] NOT NULL CONSTRAINT [DF_ProgressModifications_ModDate] DEFAULT (getutcdate()),
[LifeCycleID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[StateTime] [datetime] NOT NULL,
[FromQuantity] [int] NOT NULL,
[ToQuantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_ProgressModifications] ADD CONSTRAINT [PK_ProgressModifications] PRIMARY KEY CLUSTERED  ([ModID]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_ProgressModifications] ADD CONSTRAINT [FK_ProgressModifications_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [FloorActivity].[tbl_ProgressModifications] ADD CONSTRAINT [FK_ProgressModifications_LifeCycleProgress] FOREIGN KEY ([LifeCycleID], [DenoID], [StateTime]) REFERENCES [Accounting].[tbl_Progress] ([LifeCycleID], [DenoID], [StateTime])
GO
ALTER TABLE [FloorActivity].[tbl_ProgressModifications] ADD CONSTRAINT [FK_ProgressModifications_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
