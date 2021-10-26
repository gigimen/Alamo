CREATE TABLE [Techs].[MachineLiveGame]
(
[MachineLiveGameID] [int] NOT NULL,
[MachineLiveGameDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Chipmaster] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MachineLiveGame] ADD CONSTRAINT [PK_MacchineLiveGame] PRIMARY KEY CLUSTERED  ([MachineLiveGameID]) ON [PRIMARY]
GO
