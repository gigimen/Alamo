CREATE TABLE [Techs].[InterventiSlot]
(
[InterventoID] [int] NOT NULL,
[ProblemaSlotSubTypeID] [int] NOT NULL,
[SoluzioneSlotTypeID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiSlot] ADD CONSTRAINT [PK_InterventiSlot] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[InterventiSlot] ADD CONSTRAINT [FK_Interventi_Slot_Interventi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[Interventi] ([InterventoID])
GO
ALTER TABLE [Techs].[InterventiSlot] ADD CONSTRAINT [FK_Interventi_Slot_Soluzione_Slot] FOREIGN KEY ([SoluzioneSlotTypeID]) REFERENCES [Techs].[SoluzioneSlotTypes] ([SoluzioneSlotTypeID])
GO
ALTER TABLE [Techs].[InterventiSlot] ADD CONSTRAINT [FK_InterventiSlot_ProblemaSlotSubTypes] FOREIGN KEY ([ProblemaSlotSubTypeID]) REFERENCES [Techs].[ProblemaSlotSubTypes] ([ProblemaSlotSubTypeID])
GO
