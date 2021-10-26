CREATE TABLE [Yogi].[Badge]
(
[Number] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Yogi].[Badge] ADD CONSTRAINT [PK_Badge] PRIMARY KEY CLUSTERED  ([Number]) ON [PRIMARY]
GO
