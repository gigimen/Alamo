CREATE TABLE [Marketing].[tbl_OffertaPremi]
(
[OffertaPremioID] [int] NOT NULL IDENTITY(1, 1),
[PremioID] [int] NULL,
[PromotionID] [int] NULL,
[ConsegnaSiteTypeID] [int] NULL,
[ValiditaRitiro] [int] NULL,
[WithinNDays] [int] NULL,
[AnnuncioAlSesam] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_OffertaPremi] ADD CONSTRAINT [CK_OffertaPremi_PeriodoValiditaPromozioneIsDefined] CHECK (([GoldenClub].[fn_CheckPromotionValidityDefined]([ValiditaRitiro],[PromotionID])=(1)))
GO
ALTER TABLE [Marketing].[tbl_OffertaPremi] ADD CONSTRAINT [CK_OffertaPremi_WithiNDaysIsDefined] CHECK ((([ValiditaRitiro]=(3) AND [WithinNDays] IS NOT NULL) OR [ValiditaRitiro]<>(3)))
GO
ALTER TABLE [Marketing].[tbl_OffertaPremi] ADD CONSTRAINT [PK_OffertaPremio] PRIMARY KEY CLUSTERED  ([OffertaPremioID]) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_OffertaPremi] ADD CONSTRAINT [FK_OffertaPremi_Premi] FOREIGN KEY ([PremioID]) REFERENCES [Marketing].[tbl_Premi] ([PremioID])
GO
ALTER TABLE [Marketing].[tbl_OffertaPremi] ADD CONSTRAINT [FK_OffertaPremi_Promotions] FOREIGN KEY ([PromotionID]) REFERENCES [Marketing].[tbl_Promozioni] ([PromotionID])
GO
ALTER TABLE [Marketing].[tbl_OffertaPremi] ADD CONSTRAINT [FK_OffertaPremi_SiteTypes] FOREIGN KEY ([ConsegnaSiteTypeID]) REFERENCES [CasinoLayout].[SiteTypes] ([SiteTypeID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'1=al sesam, 2=al ristorante, 3=in cassa', 'SCHEMA', N'Marketing', 'TABLE', N'tbl_OffertaPremi', 'COLUMN', N'ConsegnaSiteTypeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0=Always,1=OnTimeOnly,2=OnePerGamingDate,3=WithinNdays,4=PromotionValidity', 'SCHEMA', N'Marketing', 'TABLE', N'tbl_OffertaPremi', 'COLUMN', N'ValiditaRitiro'
GO
