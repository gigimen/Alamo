CREATE TABLE [GeneralPurpose].[ConfigParams]
(
[VarName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VarType] [tinyint] NOT NULL,
[VarValue] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GeneralPurpose].[ConfigParams] ADD CONSTRAINT [PK_ConfigParam] PRIMARY KEY CLUSTERED  ([VarName]) ON [PRIMARY]
GO
