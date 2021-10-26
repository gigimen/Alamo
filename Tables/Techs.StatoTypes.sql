CREATE TABLE [Techs].[StatoTypes]
(
[StatoTypeID] [int] NOT NULL IDENTITY(1, 1),
[StatoTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[StatoTypes] ADD CONSTRAINT [PK_StatoTypes] PRIMARY KEY CLUSTERED  ([StatoTypeID]) ON [PRIMARY]
GO
