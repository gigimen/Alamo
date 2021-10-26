CREATE TABLE [Techs].[SoluzioneSlotTypes]
(
[SoluzioneSlotTypeID] [int] NOT NULL IDENTITY(1, 1),
[SoluzioneSlotTypeDescription] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[SoluzioneSlotTypes] ADD CONSTRAINT [PK_Soluzione_Slot] PRIMARY KEY CLUSTERED  ([SoluzioneSlotTypeID]) ON [PRIMARY]
GO
