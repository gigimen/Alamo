CREATE TABLE [Techs].[MaterialeFacilityHistory]
(
[MaterialeFacilityHistoryID] [int] NOT NULL IDENTITY(1, 1),
[MaterialeFacilityID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_MaterialeFacilityHistory_InsertTimeStampUTC] DEFAULT (getutcdate()),
[InsertUserAccessID] [int] NOT NULL,
[HistDescr] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeFacilityHistory] ADD CONSTRAINT [PK_MaterialeFacilityHistory] PRIMARY KEY CLUSTERED  ([MaterialeFacilityHistoryID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeFacilityHistory] ADD CONSTRAINT [FK_MaterialeFacilityHistory_MaterialeFacility] FOREIGN KEY ([MaterialeFacilityID]) REFERENCES [Techs].[MaterialeFacility] ([MaterialeFacilityID])
GO
ALTER TABLE [Techs].[MaterialeFacilityHistory] ADD CONSTRAINT [FK_MaterialeFacilityHistory_UserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
