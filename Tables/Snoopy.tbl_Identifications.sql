CREATE TABLE [Snoopy].[tbl_Identifications]
(
[IdentificationID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_Identifications_InsertTimeStampUTC] DEFAULT (getutcdate()),
[IdentificationUserAccessID] [int] NOT NULL,
[IDDocumentID] [int] NULL,
[IDCauseID] [int] NOT NULL,
[ChiarimentoID] [int] NULL,
[RegID] [int] NULL,
[SMCheckTimeStampUTC] [datetime] NULL,
[SMCheckUserAccessID] [int] NULL,
[Note] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gamingdate] [datetime] NOT NULL CONSTRAINT [DF_Identifications_Gamingdate] DEFAULT ([GeneralPurpose].[fn_GetGamingLocalDate2](getutcdate(),datediff(hour,getutcdate(),getdate()),(1))),
[CategoriaRischio] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Identifications_CategoriaRischio] DEFAULT ('C'),
[CancelID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Identifications] ADD CONSTRAINT [PK_Identifications] PRIMARY KEY CLUSTERED  ([IdentificationID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Identifications] ADD CONSTRAINT [IX_CUtomerIDisUnique] UNIQUE NONCLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Identifications] WITH NOCHECK ADD CONSTRAINT [FK_Identifications_Chiarimenti] FOREIGN KEY ([ChiarimentoID]) REFERENCES [Snoopy].[tbl_Chiarimenti] ([ChiarimentoID])
GO
ALTER TABLE [Snoopy].[tbl_Identifications] WITH NOCHECK ADD CONSTRAINT [FK_Identifications_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_Identifications] WITH NOCHECK ADD CONSTRAINT [FK_Identifications_IDCauses] FOREIGN KEY ([IDCauseID]) REFERENCES [Snoopy].[tbl_IDCauses] ([IdCauseID])
GO
ALTER TABLE [Snoopy].[tbl_Identifications] WITH NOCHECK ADD CONSTRAINT [FK_Identifications_IDDocuments] FOREIGN KEY ([IDDocumentID]) REFERENCES [Snoopy].[tbl_IDDocuments] ([IDDocumentID])
GO
ALTER TABLE [Snoopy].[tbl_Identifications] WITH NOCHECK ADD CONSTRAINT [FK_Identifications_Registrations] FOREIGN KEY ([RegID]) REFERENCES [Snoopy].[tbl_Registrations] ([RegID])
GO
ALTER TABLE [Snoopy].[tbl_Identifications] WITH NOCHECK ADD CONSTRAINT [FK_Identifications_UserAccesses] FOREIGN KEY ([IdentificationUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
