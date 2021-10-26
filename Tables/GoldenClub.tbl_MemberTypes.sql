CREATE TABLE [GoldenClub].[tbl_MemberTypes]
(
[MemberTypeID] [int] NOT NULL,
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClub_MemberTYpes_InsertTimeStamp] DEFAULT (getutcdate()),
[DefaultGoldenParams] [int] NOT NULL,
[CardTypeID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_MemberTypes] ADD CONSTRAINT [PK_GoldenClub_MemberTypes] PRIMARY KEY CLUSTERED  ([MemberTypeID]) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_MemberTypes] ADD CONSTRAINT [FK_MemberTypes_MemberTypes] FOREIGN KEY ([MemberTypeID]) REFERENCES [GoldenClub].[tbl_MemberTypes] ([MemberTypeID])
GO
