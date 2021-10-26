CREATE TABLE [Techs].[Priorita]
(
[PrioritaID] [int] NOT NULL,
[PrioritDescr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Priorita] ADD CONSTRAINT [PK_Priorita] PRIMARY KEY CLUSTERED  ([PrioritaID]) ON [PRIMARY]
GO
