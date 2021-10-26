CREATE TABLE [Techs].[InterventiServiziFacility]
(
[InterventoID] [int] NOT NULL,
[Provvedimento] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiServiziFacility] ADD CONSTRAINT [PK_InterventiServiziFacility] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiServiziFacility] ADD CONSTRAINT [FK_InterventiServiziFacility_InterventiServizi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[InterventiServizi] ([InterventoID])
GO
