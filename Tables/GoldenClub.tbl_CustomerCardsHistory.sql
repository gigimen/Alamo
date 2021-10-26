CREATE TABLE [GoldenClub].[tbl_CustomerCardsHistory]
(
[GoldenClubCardID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[FromUTC] [datetime] NOT NULL,
[ToUTC] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_CustomerCardsHistory] ADD CONSTRAINT [FK_CustomerCardsHistory_Cards] FOREIGN KEY ([GoldenClubCardID]) REFERENCES [GoldenClub].[tbl_Cards] ([GoldenClubCardID])
GO
ALTER TABLE [GoldenClub].[tbl_CustomerCardsHistory] WITH NOCHECK ADD CONSTRAINT [FK_CustomerCardsHistory_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
