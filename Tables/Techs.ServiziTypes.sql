CREATE TABLE [Techs].[ServiziTypes]
(
[ServiziTypeID] [int] NOT NULL IDENTITY(1, 1),
[ServiziTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ServiziTypes] ADD CONSTRAINT [PK_ServiziType] PRIMARY KEY CLUSTERED  ([ServiziTypeID]) ON [PRIMARY]
GO
