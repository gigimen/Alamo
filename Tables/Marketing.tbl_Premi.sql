CREATE TABLE [Marketing].[tbl_Premi]
(
[PremioID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[ProntaConsegna] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_Premi] ADD CONSTRAINT [PK_Premi] PRIMARY KEY CLUSTERED  ([PremioID]) ON [PRIMARY]
GO
