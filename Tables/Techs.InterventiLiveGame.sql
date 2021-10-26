CREATE TABLE [Techs].[InterventiLiveGame]
(
[InterventoID] [int] NOT NULL,
[ProblemaLiveGameSubTypeID] [int] NOT NULL,
[SoluzioneLiveGameTypeID] [int] NULL,
[MachineLiveGameID] [int] NULL,
[TableLiveGameID] [int] NULL,
[ContaOre] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiLiveGame] ADD CONSTRAINT [PK_InterventiLiveGame] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiLiveGame] ADD CONSTRAINT [FK_Interventi_LiveGame_Interventi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[Interventi] ([InterventoID])
GO
ALTER TABLE [Techs].[InterventiLiveGame] ADD CONSTRAINT [FK_Interventi_LiveGame_Soluzione_LiveGame] FOREIGN KEY ([SoluzioneLiveGameTypeID]) REFERENCES [Techs].[SoluzioneLiveGameTypes] ([SoluzioneLiveGameTypeID])
GO
ALTER TABLE [Techs].[InterventiLiveGame] ADD CONSTRAINT [FK_InterventiLiveGame_MachineLiveGame] FOREIGN KEY ([MachineLiveGameID]) REFERENCES [Techs].[MachineLiveGame] ([MachineLiveGameID])
GO
ALTER TABLE [Techs].[InterventiLiveGame] ADD CONSTRAINT [FK_InterventiLiveGame_ProblemaLiveGameTypes] FOREIGN KEY ([ProblemaLiveGameSubTypeID]) REFERENCES [Techs].[ProblemaLiveGameSubTypes] ([ProblemaLiveGameSubTypeID])
GO
ALTER TABLE [Techs].[InterventiLiveGame] ADD CONSTRAINT [FK_InterventiLiveGame_TablesLiveGame] FOREIGN KEY ([TableLiveGameID]) REFERENCES [Techs].[TableLiveGame] ([TableLiveGameID])
GO
