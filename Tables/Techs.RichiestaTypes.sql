CREATE TABLE [Techs].[RichiestaTypes]
(
[RichiestaTypeID] [int] NOT NULL IDENTITY(1, 1),
[RichiestaTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[RichiestaTypes] ADD CONSTRAINT [PK_RichiestaType] PRIMARY KEY CLUSTERED  ([RichiestaTypeID]) ON [PRIMARY]
GO
