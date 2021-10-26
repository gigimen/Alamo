CREATE TABLE [GoldenClub].[tbl_Members]
(
[CustomerID] [int] NOT NULL,
[GoldenClubCardID] [int] NULL,
[SMSNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClub_InsertTimeStamp] DEFAULT (getutcdate()),
[InsertUserAccessID] [int] NOT NULL,
[IDDocumentID] [int] NULL,
[SMSNumberCheckedTimestampUTC] [datetime] NULL,
[LinkTimeStampUTC] [datetime] NULL,
[LinkUserAccessID] [int] NULL,
[SMSNumberCheckedFromIPAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartUseMobileTimeStampUTC] [datetime] NULL,
[CancelID] [int] NULL,
[SectorID] [int] NULL,
[TotMoneyMove] [int] NULL,
[RegistrationCount] [int] NULL,
[MembershipTimeStampUTC] [datetime] NULL,
[GoldenParams] [int] NOT NULL,
[MemberTypeID] [int] NULL,
[Categoria] [int] NULL CONSTRAINT [DF_Members_Categoria] DEFAULT ((6))
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_Members] ADD CONSTRAINT [CK_Members_Categoria] CHECK (([Categoria]>=(1) AND [Categoria]<=(6)))
GO
ALTER TABLE [GoldenClub].[tbl_Members] ADD CONSTRAINT [PK_GoldenClub] PRIMARY KEY CLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_Members] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClub_CancelActions] FOREIGN KEY ([CancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] ADD CONSTRAINT [FK_GoldenClub_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClub_GoldenClubCards] FOREIGN KEY ([GoldenClubCardID]) REFERENCES [GoldenClub].[tbl_Cards] ([GoldenClubCardID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClub_IDDocuments] FOREIGN KEY ([IDDocumentID]) REFERENCES [Snoopy].[tbl_IDDocuments] ([IDDocumentID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] ADD CONSTRAINT [FK_GoldenClub_InsertUserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClub_LinkUserAccesses] FOREIGN KEY ([LinkUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClub_Sectors] FOREIGN KEY ([SectorID]) REFERENCES [CasinoLayout].[Sectors] ([SectorID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] ADD CONSTRAINT [FK_Members_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [GoldenClub].[tbl_Members] WITH NOCHECK ADD CONSTRAINT [FK_Members_MemberTypes] FOREIGN KEY ([MemberTypeID]) REFERENCES [GoldenClub].[tbl_MemberTypes] ([MemberTypeID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'da 1 a 6 (6=scrocconi)', 'SCHEMA', N'GoldenClub', 'TABLE', N'tbl_Members', 'COLUMN', N'Categoria'
GO
