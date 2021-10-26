CREATE TABLE [Techs].[StatoContatori]
(
[StatoContatoriID] [int] NOT NULL IDENTITY(1, 1),
[VisoreUserID] [int] NOT NULL,
[TIM] [int] NOT NULL,
[TIS] [int] NOT NULL,
[GM] [int] NOT NULL,
[TOM] [int] NOT NULL,
[TOS] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_StatoContatori_InsertTimeStampUTC] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[StatoContatori] ADD CONSTRAINT [PK_StatoContatori] PRIMARY KEY CLUSTERED  ([StatoContatoriID]) ON [PRIMARY]
GO
