CREATE TABLE [Snoopy].[tbl_CustomerRestituzioni]
(
[PK_RestituzioneID] [int] NOT NULL IDENTITY(1, 1),
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_CustomerRestituzioni_InsertTimeStampUTC] DEFAULT (getutcdate()),
[CustomerID] [int] NOT NULL,
[RestUserAccessID] [int] NULL,
[RestGamingDate] [datetime] NULL,
[RestTimeStampUTC] [datetime] NULL,
[FK_DenaroTrovatoID] [int] NULL,
[FK_RettificaRestituzioneID] [int] NULL,
[RappSorv] [int] NULL,
[NoVetoNotification] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerRestituzioni] ADD CONSTRAINT [CK_tbl_CustomerRestituzioni] CHECK (([FK_DenaroTrovatoID] IS NULL AND [FK_RettificaRestituzioneID] IS NOT NULL OR [FK_DenaroTrovatoID] IS NOT NULL AND [FK_RettificaRestituzioneID] IS NULL))
GO
ALTER TABLE [Snoopy].[tbl_CustomerRestituzioni] ADD CONSTRAINT [PK_CustomerRestituzioni] PRIMARY KEY CLUSTERED  ([PK_RestituzioneID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerRestituzioni] ADD CONSTRAINT [FK_tbl_CustomerRestituzioni_tbl_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerRestituzioni] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CustomerRestituzioni_tbl_DenaroTrovato] FOREIGN KEY ([FK_DenaroTrovatoID]) REFERENCES [Accounting].[tbl_DenaroTrovato] ([PK_DenaroTrovatoID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerRestituzioni] ADD CONSTRAINT [FK_tbl_CustomerRestituzioni_tbl_Rettifica_Restituzione] FOREIGN KEY ([FK_RettificaRestituzioneID]) REFERENCES [Accounting].[tbl_Rettifica_Restituzione] ([PK_RettificaRestituzioneID])
GO
