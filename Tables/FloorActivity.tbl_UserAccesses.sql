CREATE TABLE [FloorActivity].[tbl_UserAccesses]
(
[UserAccessID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[LoginDate] [datetime] NOT NULL CONSTRAINT [DF_UserAccesses_LoginDate] DEFAULT (getutcdate()),
[LogoutDate] [datetime] NULL,
[SiteID] [int] NOT NULL,
[ApplicationID] [int] NOT NULL,
[UserGroupID] [int] NOT NULL,
[LogoutForced] [smallint] NULL,
[LifeCycleID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_UserAccesses] ADD CONSTRAINT [PK_UserAccesses] PRIMARY KEY CLUSTERED  ([UserAccessID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserAccesses_LifeCycleID] ON [FloorActivity].[tbl_UserAccesses] ([LifeCycleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserAccesses_Per_site_and_Application] ON [FloorActivity].[tbl_UserAccesses] ([SiteID], [ApplicationID]) INCLUDE ([LoginDate], [LogoutDate], [UserID]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_UserAccesses] WITH NOCHECK ADD CONSTRAINT [FK_UserAccesses_Applications] FOREIGN KEY ([ApplicationID]) REFERENCES [GeneralPurpose].[Applications] ([ApplicationID])
GO
ALTER TABLE [FloorActivity].[tbl_UserAccesses] ADD CONSTRAINT [FK_UserAccesses_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [FloorActivity].[tbl_UserAccesses] WITH NOCHECK ADD CONSTRAINT [FK_UserAccesses_Sites] FOREIGN KEY ([SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
ALTER TABLE [FloorActivity].[tbl_UserAccesses] WITH NOCHECK ADD CONSTRAINT [FK_UserAccesses_UserGroups] FOREIGN KEY ([UserGroupID]) REFERENCES [CasinoLayout].[UserGroups] ([UserGroupID])
GO
ALTER TABLE [FloorActivity].[tbl_UserAccesses] WITH NOCHECK ADD CONSTRAINT [FK_UserAccesses_Users] FOREIGN KEY ([UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
GRANT SELECT ON  [FloorActivity].[tbl_UserAccesses] TO [CKeyUsage]
GO
GRANT INSERT ON  [FloorActivity].[tbl_UserAccesses] TO [LRDManagement]
GO
GRANT UPDATE ON  [FloorActivity].[tbl_UserAccesses] TO [LRDManagement]
GO
GRANT UPDATE ON  [FloorActivity].[tbl_UserAccesses] TO [SolaLetturaNoDanni]
GO
GRANT INSERT ON  [FloorActivity].[tbl_UserAccesses] TO [TecRole]
GO
GRANT UPDATE ON  [FloorActivity].[tbl_UserAccesses] TO [TecRole]
GO
