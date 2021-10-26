CREATE TABLE [Yogi].[Company]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Address] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Note] [varchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Yogi].[Company] ADD CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
