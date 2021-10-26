CREATE TABLE [CasinoLayout].[Floors]
(
[FloorID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[FDescription] [varchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Floors] ADD CONSTRAINT [PK_Floors] PRIMARY KEY CLUSTERED  ([FloorID]) ON [PRIMARY]
GO
