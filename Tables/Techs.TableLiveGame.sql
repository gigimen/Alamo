CREATE TABLE [Techs].[TableLiveGame]
(
[TableLiveGameID] [int] NOT NULL IDENTITY(1, 1),
[TableLiveGameDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[TableLiveGame] ADD CONSTRAINT [PK_TablesLiveGame] PRIMARY KEY CLUSTERED  ([TableLiveGameID]) ON [PRIMARY]
GO
