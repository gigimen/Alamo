CREATE TABLE [Techs].[SoluzioneLiveGameTypes]
(
[SoluzioneLiveGameTypeID] [int] NOT NULL,
[SoluzioneLiveGameTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[SoluzioneLiveGameTypes] ADD CONSTRAINT [PK_SoluzioneLiveGameTypes] PRIMARY KEY CLUSTERED  ([SoluzioneLiveGameTypeID]) ON [PRIMARY]
GO
