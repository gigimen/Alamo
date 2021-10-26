CREATE TABLE [Yogi].[CompanyContact]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[LastName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Phone] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[DocNumber] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[FK_IdCompany] [int] NOT NULL,
[FK_IdDocType] [int] NOT NULL,
[CheckVeto] [bit] NOT NULL,
[IdUserCheckVeto] [int] NOT NULL,
[DataCheckVeto] [datetime] NOT NULL,
[Note] [varchar] (max) COLLATE Latin1_General_CI_AS NULL,
[DocImage] [image] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Yogi].[CompanyContact] ADD CONSTRAINT [PK_CompanyContact] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
