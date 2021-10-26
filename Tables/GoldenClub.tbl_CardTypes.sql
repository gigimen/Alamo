CREATE TABLE [GoldenClub].[tbl_CardTypes]
(
[CardTypeID] [int] NOT NULL,
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsPersonal] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_CardTypes] ADD CONSTRAINT [PK_CardTypes] PRIMARY KEY CLUSTERED  ([CardTypeID]) ON [PRIMARY]
GO
