CREATE TABLE [Snoopy].[tbl_Registrations]
(
[RegID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[StockID] [int] NOT NULL,
[TimeStampUTC] [datetime] NOT NULL,
[gamingDate] [smalldatetime] NOT NULL,
[CauseID] [int] NOT NULL,
[AmountSFr] [int] NOT NULL,
[UserAccessID] [int] NOT NULL,
[CancelID] [int] NULL,
[TimeStampLoc] [datetime] NOT NULL,
[Nota] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Registrations] ADD CONSTRAINT [PK_Registrations2] PRIMARY KEY CLUSTERED  ([RegID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PK_RegsitrationsByGamingDate] ON [Snoopy].[tbl_Registrations] ([gamingDate], [CancelID]) INCLUDE ([AmountSFr], [CauseID], [CustomerID], [TimeStampLoc]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Registrations] ADD CONSTRAINT [FK_Registrations2_CancelActions] FOREIGN KEY ([CancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Snoopy].[tbl_Registrations] ADD CONSTRAINT [FK_Registrations2_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_Registrations] ADD CONSTRAINT [FK_Registrations2_IDCauses] FOREIGN KEY ([CauseID]) REFERENCES [Snoopy].[tbl_IDCauses] ([IdCauseID])
GO
ALTER TABLE [Snoopy].[tbl_Registrations] ADD CONSTRAINT [FK_Registrations2_Stocks] FOREIGN KEY ([StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
ALTER TABLE [Snoopy].[tbl_Registrations] ADD CONSTRAINT [FK_Registrations2_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
