CREATE TABLE [Reception].[tbl_FasceEtaRegistrations]
(
[PK_VetoIngresso] [int] NOT NULL IDENTITY(1, 1),
[GamingDate] [datetime] NULL CONSTRAINT [DF_tbl_Ingressi_GamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingLocalDate2](getdate(),(0),(22))),
[entratatimestampUTC] [datetime] NOT NULL CONSTRAINT [DF_IngressoVeto_entratatimestampUTC] DEFAULT (getutcdate()),
[entratatimestampLoc] [datetime] NOT NULL CONSTRAINT [DF_IngressoVeto_entratatimestampLoc] DEFAULT (getdate()),
[FK_ControlID] [int] NOT NULL,
[FasciaEtaID] [int] NULL,
[Sesso] [bit] NULL,
[ProvenienzaID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Reception].[tbl_FasceEtaRegistrations] ADD CONSTRAINT [PK_tbl_Ingressi] PRIMARY KEY CLUSTERED  ([PK_VetoIngresso]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Fasceeta_by_ControlID] ON [Reception].[tbl_FasceEtaRegistrations] ([FK_ControlID]) INCLUDE ([GamingDate], [entratatimestampLoc]) ON [PRIMARY]
GO
ALTER TABLE [Reception].[tbl_FasceEtaRegistrations] ADD CONSTRAINT [FK_IngressiVeto_Ingressi_VetoControl] FOREIGN KEY ([FK_ControlID]) REFERENCES [Reception].[tbl_VetoControls] ([PK_ControllID])
GO
ALTER TABLE [Reception].[tbl_FasceEtaRegistrations] ADD CONSTRAINT [FK_tbl_FasceEtaRegistrations_tbl_FasceEta] FOREIGN KEY ([FasciaEtaID]) REFERENCES [Snoopy].[tbl_FasceEta] ([FasciaEtaID])
GO
ALTER TABLE [Reception].[tbl_FasceEtaRegistrations] ADD CONSTRAINT [FK_tbl_FasceEtaRegistrations_tbl_Provenienza] FOREIGN KEY ([ProvenienzaID]) REFERENCES [Snoopy].[tbl_Provenienza] ([ProvenienzaID])
GO
