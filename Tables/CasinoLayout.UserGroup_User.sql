CREATE TABLE [CasinoLayout].[UserGroup_User]
(
[UserGroupID] [int] NOT NULL,
[UserID] [int] NOT NULL,
[SectorID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroup_User] ADD CONSTRAINT [PK_UserGroup_User] PRIMARY KEY CLUSTERED  ([UserGroupID], [UserID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroup_User] ADD CONSTRAINT [FK_UserGroup_User_Sectors] FOREIGN KEY ([SectorID]) REFERENCES [CasinoLayout].[Sectors] ([SectorID])
GO
ALTER TABLE [CasinoLayout].[UserGroup_User] WITH NOCHECK ADD CONSTRAINT [FK_UserGroup_User_UserGroups] FOREIGN KEY ([UserGroupID]) REFERENCES [CasinoLayout].[UserGroups] ([UserGroupID])
GO
ALTER TABLE [CasinoLayout].[UserGroup_User] ADD CONSTRAINT [FK_UserGroup_User_Users] FOREIGN KEY ([UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
