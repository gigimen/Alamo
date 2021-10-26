CREATE TABLE [GeneralPurpose].[Applications]
(
[ApplicationID] [int] NOT NULL,
[FName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GeneralPurpose].[Applications] ADD CONSTRAINT [PK_Applications] PRIMARY KEY CLUSTERED  ([ApplicationID]) ON [PRIMARY]
GO
