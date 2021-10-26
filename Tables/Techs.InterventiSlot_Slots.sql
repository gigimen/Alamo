CREATE TABLE [Techs].[InterventiSlot_Slots]
(
[InterventoID] [int] NOT NULL,
[COD_MACHIN] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DAT_DDEF] [datetime] NOT NULL,
[FloorSfr] [bit] NOT NULL,
[RAMClearID] [int] NULL,
[CambioMeccaniciID] [int] NULL,
[StatoContatoriID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiSlot_Slots] ADD CONSTRAINT [FK_InterventiSlot_Slots_CambioMeccanici] FOREIGN KEY ([CambioMeccaniciID]) REFERENCES [Techs].[CambioMeccanici] ([CambioMeccaniciID])
GO
ALTER TABLE [Techs].[InterventiSlot_Slots] ADD CONSTRAINT [FK_InterventiSlot_Slots_StatoContatori] FOREIGN KEY ([StatoContatoriID]) REFERENCES [Techs].[StatoContatori] ([StatoContatoriID])
GO
ALTER TABLE [Techs].[InterventiSlot_Slots] ADD CONSTRAINT [FK_InterventoSlot_Slots_InterventiSlot] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[InterventiSlot] ([InterventoID])
GO
ALTER TABLE [Techs].[InterventiSlot_Slots] ADD CONSTRAINT [FK_InterventoSlot_Slots_RAMClear] FOREIGN KEY ([RAMClearID]) REFERENCES [Techs].[RAMClear] ([RAMClearID])
GO
