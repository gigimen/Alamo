CREATE TABLE [Snoopy].[tbl_GreenPass]
(
[GreenpassID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GreenPass_InsertTimeStampUTC] DEFAULT (getutcdate()),
[Scadenza] [datetime] NOT NULL,
[Scaduto] AS (case  when [Scadenza]<[GeneralPurpose].[fn_GetGamingDate](getdate(),(0),(10)) then (1) else (0) end)
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_GreenPass] ADD CONSTRAINT [PK_GreenPass] PRIMARY KEY CLUSTERED  ([GreenpassID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_GreenPass] ADD CONSTRAINT [IX_CustomerIDisUnique] UNIQUE NONCLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_GreenPass] WITH NOCHECK ADD CONSTRAINT [FK_GreenPass_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
