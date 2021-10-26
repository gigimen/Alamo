CREATE TABLE [Marketing].[tbl_Eventi]
(
[EventoID] [int] NOT NULL IDENTITY(1, 1),
[SMSInvito] [varchar] (480) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Nome] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GamingDate] [datetime] NOT NULL,
[StartTimestampUTC] [datetime] NOT NULL,
[StopTimeStampUTC] [datetime] NOT NULL,
[DragonAndGolden] [int] NOT NULL,
[ProjectorComputer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Auguri] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumVincitori] [int] NULL,
[PromotionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_Eventi] ADD CONSTRAINT [CK_EventiMarketing] CHECK (([DragonAndGolden]=(2) OR [DragonAndGolden]=(1) OR [DragonAndGolden]=(0)))
GO
ALTER TABLE [Marketing].[tbl_Eventi] ADD CONSTRAINT [PK_GoldenClubEventiMarketing] PRIMARY KEY CLUSTERED  ([EventoID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'GoldenOnly = 0, GoldenAndDragon = 1, DragonOnly = 2', 'SCHEMA', N'Marketing', 'TABLE', N'tbl_Eventi', 'COLUMN', N'DragonAndGolden'
GO
