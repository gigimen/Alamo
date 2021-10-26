CREATE TABLE [GoldenClub].[tbl_CardEntryMode]
(
[PK_CardEntryModeID] [int] NOT NULL,
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_CardEntryMode] ADD CONSTRAINT [PK_CardEntryMode] PRIMARY KEY CLUSTERED  ([PK_CardEntryModeID]) ON [PRIMARY]
GO
