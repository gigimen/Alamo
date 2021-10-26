CREATE TABLE [Snoopy].[tbl_CustomerDocPDF]
(
[PDFID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[OriginalFileName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL,
[InsertUserAccessID] [int] NOT NULL,
[GamingDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerDocPDF] ADD CONSTRAINT [PK_ChiarimentiPDF] PRIMARY KEY CLUSTERED  ([PDFID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerDocPDF] ADD CONSTRAINT [FK_ChiarimentiPDF_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerDocPDF] ADD CONSTRAINT [FK_ChiarimentiPDF_UserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
GRANT DELETE ON  [Snoopy].[tbl_CustomerDocPDF] TO [SolaLetturaNoDanni]
GO
GRANT INSERT ON  [Snoopy].[tbl_CustomerDocPDF] TO [SolaLetturaNoDanni]
GO
GRANT SELECT ON  [Snoopy].[tbl_CustomerDocPDF] TO [SolaLetturaNoDanni]
GO
GRANT UPDATE ON  [Snoopy].[tbl_CustomerDocPDF] TO [SolaLetturaNoDanni]
GO
