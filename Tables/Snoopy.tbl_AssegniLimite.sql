CREATE TABLE [Snoopy].[tbl_AssegniLimite]
(
[CustomerId] [int] NOT NULL,
[Limite] [int] NOT NULL,
[Nota] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_AssegniLimite] ADD CONSTRAINT [PK_AssegniLimite] PRIMARY KEY CLUSTERED  ([CustomerId]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_AssegniLimite] ADD CONSTRAINT [FK_AssegniLimite_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
