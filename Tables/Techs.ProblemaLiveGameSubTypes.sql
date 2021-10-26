CREATE TABLE [Techs].[ProblemaLiveGameSubTypes]
(
[ProblemaLiveGameSubTypeID] [int] NOT NULL,
[ProblemaLiveGameSubTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProblemaLiveGameTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ProblemaLiveGameSubTypes] ADD CONSTRAINT [PK_ProblemaLiveGameSubTypes] PRIMARY KEY CLUSTERED  ([ProblemaLiveGameSubTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ProblemaLiveGameSubTypes] ADD CONSTRAINT [FK_ProblemaLiveGameSubTypes_ProblemaLiveGameTypes] FOREIGN KEY ([ProblemaLiveGameTypeID]) REFERENCES [Techs].[ProblemaLiveGameTypes] ([ProblemaLiveGameTypeID])
GO
