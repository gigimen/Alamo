CREATE TABLE [Marketing].[tbl_Promozioni]
(
[PromotionID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[ValidaDal] [datetime] NULL,
[ValidaAl] [datetime] NULL,
[PromotionScope] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_Promozioni] ADD CONSTRAINT [CK_Promotions_PromotionScope] CHECK (([PromotionScope]=(2) OR [PromotionScope]=(1) OR [PromotionScope]=(0)))
GO
ALTER TABLE [Marketing].[tbl_Promozioni] ADD CONSTRAINT [CK_Promotions_Validita_Durata] CHECK (([ValidaDal] IS NULL AND [ValidaAl] IS NULL OR ([ValidaDal] IS NOT NULL AND [ValidaAl] IS NULL) OR [ValidaDal]<=[ValidaAl]))
GO
ALTER TABLE [Marketing].[tbl_Promozioni] ADD CONSTRAINT [PK_Promotions] PRIMARY KEY CLUSTERED  ([PromotionID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = GoldenOnly, 1=Golden and Dragon, 2=DragonOnly', 'SCHEMA', N'Marketing', 'TABLE', N'tbl_Promozioni', 'COLUMN', N'PromotionScope'
GO
