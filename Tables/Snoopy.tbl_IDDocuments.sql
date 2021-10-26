CREATE TABLE [Snoopy].[tbl_IDDocuments]
(
[IDDocumentID] [int] NOT NULL IDENTITY(1, 1),
[IDDocTypeID] [int] NOT NULL,
[ExpirationDate] [datetime] NOT NULL,
[CustomerID] [int] NOT NULL,
[DocNumber] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserAccessID] [int] NOT NULL,
[Address] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_IDDocuments_InsertTimeStampUTC] DEFAULT (getutcdate()),
[CitizenshipID] [int] NOT NULL,
[DomicilioID] [int] NOT NULL,
[InsertGamingDate] [datetime] NOT NULL CONSTRAINT [DF_IDDocuments_InsertGamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingLocalDate2](getutcdate(),datediff(hour,getutcdate(),getdate()),(1)))
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_IDDocuments] ADD CONSTRAINT [PK_IDDocuments] PRIMARY KEY CLUSTERED  ([IDDocumentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IDDocuments_IDDocTypeID] ON [Snoopy].[tbl_IDDocuments] ([IDDocTypeID]) INCLUDE ([CitizenshipID], [CustomerID], [DomicilioID], [InsertTimeStampUTC], [UserAccessID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IDDocuments_InsertGamingDate] ON [Snoopy].[tbl_IDDocuments] ([InsertGamingDate]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_IDDocuments] WITH NOCHECK ADD CONSTRAINT [FK_IDDocuments_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_IDDocuments] WITH NOCHECK ADD CONSTRAINT [FK_IDDocuments_IDDocTypes] FOREIGN KEY ([IDDocTypeID]) REFERENCES [Snoopy].[tbl_IDDocTypes] ([IDDocTypeID])
GO
ALTER TABLE [Snoopy].[tbl_IDDocuments] WITH NOCHECK ADD CONSTRAINT [FK_IDDocuments_Nazioni] FOREIGN KEY ([CitizenshipID]) REFERENCES [Snoopy].[tbl_Nazioni] ([NazioneID])
GO
ALTER TABLE [Snoopy].[tbl_IDDocuments] WITH NOCHECK ADD CONSTRAINT [FK_IDDocuments_Nazioni_Domicilio] FOREIGN KEY ([DomicilioID]) REFERENCES [Snoopy].[tbl_Nazioni] ([NazioneID])
GO
GRANT SELECT ON  [Snoopy].[tbl_IDDocuments] TO [CKeyUsage]
GO
