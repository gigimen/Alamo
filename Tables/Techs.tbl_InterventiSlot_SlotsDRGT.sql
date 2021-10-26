CREATE TABLE [Techs].[tbl_InterventiSlot_SlotsDRGT]
(
[InterventoID] [int] NOT NULL,
[IpAddr] [int] NOT NULL,
[RAMClearID] [int] NULL,
[StatoContatoriID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[tbl_InterventiSlot_SlotsDRGT] ADD CONSTRAINT [FK_InterventiSlot_Slots_InterventiSlot] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[InterventiSlot] ([InterventoID])
GO
ALTER TABLE [Techs].[tbl_InterventiSlot_SlotsDRGT] ADD CONSTRAINT [FK_InterventiSlot_SlotsDRGT_InterventiSlot] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[InterventiSlot] ([InterventoID])
GO
ALTER TABLE [Techs].[tbl_InterventiSlot_SlotsDRGT] ADD CONSTRAINT [FK_InterventiSlot_SlotsDRGT_RAMClear] FOREIGN KEY ([RAMClearID]) REFERENCES [Techs].[RAMClear] ([RAMClearID])
GO
ALTER TABLE [Techs].[tbl_InterventiSlot_SlotsDRGT] ADD CONSTRAINT [FK_InterventiSlot_SlotsDRGT_StatoContatori] FOREIGN KEY ([StatoContatoriID]) REFERENCES [Techs].[StatoContatori] ([StatoContatoriID])
GO
