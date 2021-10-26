CREATE TABLE [GoldenClub].[tbl_Cards]
(
[GoldenClubCardID] [int] NOT NULL,
[CardStatusID] [int] NOT NULL CONSTRAINT [DF_GoldenClubCards_CardStatus] DEFAULT ((4)),
[CustomerID] [int] NULL,
[InsertTimeStampUTC] [datetime] NULL,
[CancelID] [int] NULL,
[CardTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_Cards] ADD CONSTRAINT [PK_GoldenClubCards] PRIMARY KEY CLUSTERED  ([GoldenClubCardID]) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_Cards] ADD CONSTRAINT [FK_Cards_CardTypes] FOREIGN KEY ([CardTypeID]) REFERENCES [GoldenClub].[tbl_CardTypes] ([CardTypeID])
GO
ALTER TABLE [GoldenClub].[tbl_Cards] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubCards_CancelActions] FOREIGN KEY ([CancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [GoldenClub].[tbl_Cards] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubCards_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [GoldenClub].[tbl_Cards] ADD CONSTRAINT [FK_GoldenClubCards_GoldenClubCardStatus] FOREIGN KEY ([CardStatusID]) REFERENCES [GoldenClub].[tbl_CardStatus] ([CardStatusID])
GO
