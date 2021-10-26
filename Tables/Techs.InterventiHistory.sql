CREATE TABLE [Techs].[InterventiHistory]
(
[InterventoHistoryID] [int] NOT NULL IDENTITY(1, 1),
[InterventoID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL,
[InsertUserAccessID] [int] NOT NULL,
[HistDescr] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiHistory] ADD CONSTRAINT [PK_Techs_InterventiHistory] PRIMARY KEY CLUSTERED  ([InterventoHistoryID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiHistory] ADD CONSTRAINT [FK_InterventiHistory_Interventi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[Interventi] ([InterventoID])
GO
ALTER TABLE [Techs].[InterventiHistory] ADD CONSTRAINT [FK_InterventiHistory_UserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
