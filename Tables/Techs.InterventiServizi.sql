CREATE TABLE [Techs].[InterventiServizi]
(
[InterventoID] [int] NOT NULL,
[ServiziTypeID] [int] NOT NULL,
[AllarmeTypeID] [int] NULL,
[DittaID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiServizi] ADD CONSTRAINT [CK_InterventiServizi_Allarme] CHECK (([ServiziTypeID]=(1) AND [AllarmeTypeID] IS NOT NULL OR [ServiziTypeID]<>(1) AND [AllarmeTypeID] IS NULL))
GO
ALTER TABLE [Techs].[InterventiServizi] ADD CONSTRAINT [PK_InterventiServizi] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiServizi] ADD CONSTRAINT [FK_Interventi_Servizi_Interventi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[Interventi] ([InterventoID])
GO
ALTER TABLE [Techs].[InterventiServizi] ADD CONSTRAINT [FK_InterventiServizi_AllarmeType] FOREIGN KEY ([AllarmeTypeID]) REFERENCES [Techs].[AllarmeTypes] ([AllarmeTypeID])
GO
ALTER TABLE [Techs].[InterventiServizi] ADD CONSTRAINT [FK_InterventiServizi_Ditta] FOREIGN KEY ([DittaID]) REFERENCES [Techs].[Ditte] ([DittaID])
GO
ALTER TABLE [Techs].[InterventiServizi] ADD CONSTRAINT [FK_InterventiServizi_ServiziType] FOREIGN KEY ([ServiziTypeID]) REFERENCES [Techs].[ServiziTypes] ([ServiziTypeID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'if of type allarme allarem has to be defined', 'SCHEMA', N'Techs', 'TABLE', N'InterventiServizi', 'CONSTRAINT', N'CK_InterventiServizi_Allarme'
GO
