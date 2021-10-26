CREATE TABLE [Snoopy].[tbl_Nazioni]
(
[NazioneID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ForcePepCheck] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Nazioni] ADD CONSTRAINT [PK_Nazioni] PRIMARY KEY CLUSTERED  ([NazioneID]) ON [PRIMARY]
GO
