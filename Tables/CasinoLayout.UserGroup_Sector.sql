CREATE TABLE [CasinoLayout].[UserGroup_Sector]
(
[UserGroupID] [int] NOT NULL,
[SectorID] [int] NOT NULL,
[Hierarchy] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroup_Sector] ADD CONSTRAINT [PK_Group_Sector] PRIMARY KEY CLUSTERED  ([UserGroupID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroup_Sector] ADD CONSTRAINT [FK_Group_Sector_Sectors] FOREIGN KEY ([SectorID]) REFERENCES [CasinoLayout].[Sectors] ([SectorID])
GO
ALTER TABLE [CasinoLayout].[UserGroup_Sector] WITH NOCHECK ADD CONSTRAINT [FK_Group_Sector_UserGroups] FOREIGN KEY ([UserGroupID]) REFERENCES [CasinoLayout].[UserGroups] ([UserGroupID])
GO
