CREATE TABLE [GoldenClub].[tbl_TipoCene]
(
[TipoCenaID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_TipoCene] ADD CONSTRAINT [PK_TipoCene] PRIMARY KEY CLUSTERED  ([TipoCenaID]) ON [PRIMARY]
GO
