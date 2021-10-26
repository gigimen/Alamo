CREATE TABLE [Techs].[Ditte]
(
[DittaID] [int] NOT NULL IDENTITY(1, 1),
[DittaDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Ditte] ADD CONSTRAINT [PK_Ditta] PRIMARY KEY CLUSTERED  ([DittaID]) ON [PRIMARY]
GO
