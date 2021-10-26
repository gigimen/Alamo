CREATE TABLE [Snoopy].[tbl_PepChecks]
(
[PepCheckID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL,
[InsertUserAccessID] [int] NOT NULL,
[PepCheckYear] [int] NOT NULL,
[IsPep] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_PepChecks] ADD CONSTRAINT [PK_PepChecks] PRIMARY KEY CLUSTERED  ([PepCheckID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_PepChecks] ADD CONSTRAINT [IX_PepChecksOnePeryear] UNIQUE NONCLUSTERED  ([CustomerID], [PepCheckYear]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_PepChecks] ADD CONSTRAINT [FK_PepChecks_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_PepChecks] ADD CONSTRAINT [FK_PepChecks_UserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
GRANT DELETE ON  [Snoopy].[tbl_PepChecks] TO [SolaLetturaNoDanni]
GO
GRANT INSERT ON  [Snoopy].[tbl_PepChecks] TO [SolaLetturaNoDanni]
GO
GRANT UPDATE ON  [Snoopy].[tbl_PepChecks] TO [SolaLetturaNoDanni]
GO
