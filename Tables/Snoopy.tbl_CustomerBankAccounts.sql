CREATE TABLE [Snoopy].[tbl_CustomerBankAccounts]
(
[BankAccountID] [int] NOT NULL IDENTITY(1, 1),
[AccountNr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerID] [int] NOT NULL,
[BankName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IBAN] [char] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BankAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SWIFT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_CustomerBankAccounts_InsertTimeStampUTC] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerBankAccounts] ADD CONSTRAINT [PK_CustomerBankAccounts] PRIMARY KEY CLUSTERED  ([BankAccountID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerBankAccounts] WITH NOCHECK ADD CONSTRAINT [FK_CustomerBankAccounts_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
