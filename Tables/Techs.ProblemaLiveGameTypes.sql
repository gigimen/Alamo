CREATE TABLE [Techs].[ProblemaLiveGameTypes]
(
[ProblemaLiveGameTypeID] [int] NOT NULL IDENTITY(1, 1),
[ProblemaLiveGameTypeDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[ProblemaLiveGameTypes] ADD CONSTRAINT [PK_ProblemaLiveGameTypes] PRIMARY KEY CLUSTERED  ([ProblemaLiveGameTypeID]) ON [PRIMARY]
GO
