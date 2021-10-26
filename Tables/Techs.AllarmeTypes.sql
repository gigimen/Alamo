CREATE TABLE [Techs].[AllarmeTypes]
(
[AllarmeTypeID] [int] NOT NULL IDENTITY(1, 1),
[AllarmeTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[AllarmeTypes] ADD CONSTRAINT [PK_AllarmeType] PRIMARY KEY CLUSTERED  ([AllarmeTypeID]) ON [PRIMARY]
GO
