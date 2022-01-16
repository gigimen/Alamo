CREATE TABLE [CasinoLayout].[tbl_TorneoPokerDayType]
(
[PK_DayTypeID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_TorneoPokerDayType] ADD CONSTRAINT [PK_tbl_TorneoPokerDayType] PRIMARY KEY CLUSTERED  ([PK_DayTypeID]) ON [PRIMARY]
GO
