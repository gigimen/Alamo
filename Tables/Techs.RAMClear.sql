CREATE TABLE [Techs].[RAMClear]
(
[RAMClearID] [int] NOT NULL IDENTITY(1, 1),
[VisoreUserID] [int] NOT NULL,
[TIMPrima] [int] NULL,
[TIMDopo] [int] NULL,
[TISPrima] [int] NOT NULL,
[TISDopo] [int] NOT NULL,
[GMPrima] [int] NOT NULL,
[GMDopo] [int] NOT NULL,
[TOMPrima] [int] NULL,
[TOMDopo] [int] NULL,
[TOSPrima] [int] NOT NULL,
[TOSDopo] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_RAMClear_InsertTimeStampUTC] DEFAULT (getutcdate()),
[EseguitoRAMClear] [bit] NULL,
[EseguitoGiochiTest] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[RAMClear] ADD CONSTRAINT [PK_RAMClear] PRIMARY KEY CLUSTERED  ([RAMClearID]) ON [PRIMARY]
GO
