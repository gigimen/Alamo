CREATE TABLE [Techs].[StatiOrdine]
(
[StatoOrdineID] [int] NOT NULL IDENTITY(1, 1),
[StatoOrdineDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[StatiOrdine] ADD CONSTRAINT [PK_StatoOrdine] PRIMARY KEY CLUSTERED  ([StatoOrdineID]) ON [PRIMARY]
GO
