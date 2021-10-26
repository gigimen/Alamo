CREATE TABLE [Techs].[CambioMeccanici]
(
[CambioMeccaniciID] [int] NOT NULL IDENTITY(1, 1),
[VisoreUserID] [int] NOT NULL,
[TIMPrima] [int] NULL,
[TIMDopo] [int] NULL,
[TOMPrima] [int] NULL,
[TOMDopo] [int] NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_CambioMeccanici_InsertTimeStampUTC] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[CambioMeccanici] ADD CONSTRAINT [PK_CambioMeccanici] PRIMARY KEY CLUSTERED  ([CambioMeccaniciID]) ON [PRIMARY]
GO
