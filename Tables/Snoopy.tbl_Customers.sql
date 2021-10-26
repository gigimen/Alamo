CREATE TABLE [Snoopy].[tbl_Customers]
(
[CustomerID] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[InsertDate] [datetime] NOT NULL CONSTRAINT [DF_Customers_InsertDate] DEFAULT (getutcdate()),
[InsertUserAccessID] [int] NOT NULL,
[BirthDate] [datetime] NOT NULL,
[CustCancelID] [int] NULL,
[IdentificationID] [int] NULL,
[NrTelefono] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sesso] [bit] NOT NULL CONSTRAINT [DF_Customers_Sesso] DEFAULT ((0)),
[SectorID] [int] NULL,
[Comment] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Customers] ADD CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Customers] ON [Snoopy].[tbl_Customers] ([LastName]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Customers] ADD CONSTRAINT [IX_Name_Must_Be_Unique] UNIQUE NONCLUSTERED  ([LastName], [FirstName], [BirthDate]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Customers] WITH NOCHECK ADD CONSTRAINT [FK_Customers_CancelActions] FOREIGN KEY ([CustCancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Snoopy].[tbl_Customers] WITH NOCHECK ADD CONSTRAINT [FK_Customers_Identifications] FOREIGN KEY ([IdentificationID]) REFERENCES [Snoopy].[tbl_Identifications] ([IdentificationID])
GO
ALTER TABLE [Snoopy].[tbl_Customers] ADD CONSTRAINT [FK_Customers_Sectors] FOREIGN KEY ([SectorID]) REFERENCES [CasinoLayout].[Sectors] ([SectorID])
GO
ALTER TABLE [Snoopy].[tbl_Customers] WITH NOCHECK ADD CONSTRAINT [FK_Customers_UserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
GRANT SELECT ON  [Snoopy].[tbl_Customers] TO [CKeyUsage]
GO
EXEC sp_addextendedproperty N'MS_Description', N'date of first insert of the customer', 'SCHEMA', N'Snoopy', 'TABLE', N'tbl_Customers', 'COLUMN', N'InsertDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = Maschio 1 = Femmina (default Maschio)', 'SCHEMA', N'Snoopy', 'TABLE', N'tbl_Customers', 'COLUMN', N'Sesso'
GO
