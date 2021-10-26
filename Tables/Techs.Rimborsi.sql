CREATE TABLE [Techs].[Rimborsi]
(
[InterventoID] [int] NOT NULL,
[TimeStampUTC] [datetime] NOT NULL,
[CustomerID] [int] NOT NULL,
[IDDocumentID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Rimborsi] ADD CONSTRAINT [PK_Techs_Rimborsi] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Rimborsi] ADD CONSTRAINT [FK_Rimborsi_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Techs].[Rimborsi] ADD CONSTRAINT [FK_Rimborsi_IDDocuments] FOREIGN KEY ([IDDocumentID]) REFERENCES [Snoopy].[tbl_IDDocuments] ([IDDocumentID])
GO
ALTER TABLE [Techs].[Rimborsi] ADD CONSTRAINT [FK_Rimborsi_RapportiTecnici] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[RapportiTecnici] ([InterventoID])
GO
