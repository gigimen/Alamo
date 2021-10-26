CREATE TABLE [CasinoLayout].[OperationTypes]
(
[OpTypeID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[OperationTypes] ADD CONSTRAINT [PK_OperationTypes] PRIMARY KEY CLUSTERED  ([OpTypeID]) ON [PRIMARY]
GO
