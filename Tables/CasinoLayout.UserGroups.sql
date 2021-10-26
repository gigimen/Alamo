CREATE TABLE [CasinoLayout].[UserGroups]
(
[UserGroupID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RoleName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangeOfGamingDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[UserGroups] ADD CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED  ([UserGroupID]) ON [PRIMARY]
GO
GRANT SELECT ON  [CasinoLayout].[UserGroups] TO [CKeyUsage]
GO
