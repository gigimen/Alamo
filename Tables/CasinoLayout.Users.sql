CREATE TABLE [CasinoLayout].[Users]
(
[UserID] [int] NOT NULL IDENTITY(1, 1),
[loginName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varbinary] (50) NULL,
[Password2] [varbinary] (50) NULL,
[Password3] [varbinary] (50) NULL,
[LastPasswordChange] [datetime] NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BeginDate] [smalldatetime] NOT NULL,
[EndDate] [smalldatetime] NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LongName] AS (([Lastname]+' ')+[FirstName]),
[Initials] AS (upper(left([LastName],(1))+left([FirstName],(1))))
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Users] ADD CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED  ([UserID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Users] ADD CONSTRAINT [IX_UsernameMustBeUnique] UNIQUE NONCLUSTERED  ([FirstName], [LastName]) ON [PRIMARY]
GO
GRANT SELECT ON  [CasinoLayout].[Users] TO [CKeyUsage]
GO
