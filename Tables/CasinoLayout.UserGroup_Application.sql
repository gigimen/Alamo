CREATE TABLE [CasinoLayout].[UserGroup_Application]
(
[UserGroupID] [int] NOT NULL,
[ApplicationID] [int] NOT NULL,
[AllowedActions] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroup_Application] ADD CONSTRAINT [PK_UserGroup_Application] PRIMARY KEY CLUSTERED  ([UserGroupID], [ApplicationID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroup_Application] WITH NOCHECK ADD CONSTRAINT [FK_UserGroup_Application_Applications] FOREIGN KEY ([ApplicationID]) REFERENCES [GeneralPurpose].[Applications] ([ApplicationID])
GO
ALTER TABLE [CasinoLayout].[UserGroup_Application] WITH NOCHECK ADD CONSTRAINT [FK_UserGroup_Application_UserGroup] FOREIGN KEY ([UserGroupID]) REFERENCES [CasinoLayout].[UserGroups] ([UserGroupID])
GO
