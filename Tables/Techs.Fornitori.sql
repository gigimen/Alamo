CREATE TABLE [Techs].[Fornitori]
(
[FornitoreID] [int] NOT NULL IDENTITY(1, 1),
[FornitoreDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Fornitori] ADD CONSTRAINT [PK_Fornitore] PRIMARY KEY CLUSTERED  ([FornitoreID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FornitoreDescription] ON [Techs].[Fornitori] ([FornitoreDescription], [Facility]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'1=Fornitore facility 0=MaterialeTecnico', 'SCHEMA', N'Techs', 'TABLE', N'Fornitori', 'COLUMN', N'Facility'
GO
