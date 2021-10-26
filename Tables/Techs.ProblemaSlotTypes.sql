CREATE TABLE [Techs].[ProblemaSlotTypes]
(
[ProblemaSlotTypeID] [int] NOT NULL IDENTITY(1, 1),
[ProblemaSlotTypeDescription] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ProblemaSlotTypes] ADD CONSTRAINT [PK_ProblemaSlotType] PRIMARY KEY CLUSTERED  ([ProblemaSlotTypeID]) ON [PRIMARY]
GO
