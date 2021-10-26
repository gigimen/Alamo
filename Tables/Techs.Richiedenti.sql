CREATE TABLE [Techs].[Richiedenti]
(
[RichiedenteID] [int] NOT NULL IDENTITY(1, 1),
[NomeReparto] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Email] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Richiedente] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Richiedenti] ADD CONSTRAINT [PK_Techs_Richiedenti] PRIMARY KEY CLUSTERED  ([RichiedenteID]) ON [PRIMARY]
GO
