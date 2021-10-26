CREATE TABLE [Marketing].[tbl_ConsegnaPromozione]
(
[PremioID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_ConsegnaPromozione_InsertTimeStampUTC] DEFAULT (getutcdate()),
[GamingDate] [datetime] NOT NULL,
[UserAccessID] [int] NOT NULL,
[PromotionID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_ConsegnaPromozione] ADD CONSTRAINT [PK_ConsegnaPromozione] PRIMARY KEY CLUSTERED  ([CustomerID], [GamingDate], [PromotionID]) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_ConsegnaPromozione] ADD CONSTRAINT [FK_ConsegnaPromozione_Premi] FOREIGN KEY ([PremioID]) REFERENCES [Marketing].[tbl_Premi] ([PremioID])
GO
ALTER TABLE [Marketing].[tbl_ConsegnaPromozione] ADD CONSTRAINT [FK_tbl_ConsegnaPromozione_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
