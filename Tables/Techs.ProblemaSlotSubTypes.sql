CREATE TABLE [Techs].[ProblemaSlotSubTypes]
(
[ProblemaSlotSubTypeID] [int] NOT NULL IDENTITY(1, 1),
[ProblemaSlotSubTypeDescription] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProblemaSlotTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ProblemaSlotSubTypes] ADD CONSTRAINT [PK_ProblemaSlotSubTypes] PRIMARY KEY CLUSTERED  ([ProblemaSlotSubTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ProblemaSlotSubTypes] ADD CONSTRAINT [FK_ProblemaSlotSubTypes_ProblemaSlotTypes] FOREIGN KEY ([ProblemaSlotTypeID]) REFERENCES [Techs].[ProblemaSlotTypes] ([ProblemaSlotTypeID])
GO
