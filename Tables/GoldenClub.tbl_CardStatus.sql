CREATE TABLE [GoldenClub].[tbl_CardStatus]
(
[CardStatusID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_CardStatus] ADD CONSTRAINT [PK_GoldenClubCardStatus] PRIMARY KEY CLUSTERED  ([CardStatusID]) ON [PRIMARY]
GO
