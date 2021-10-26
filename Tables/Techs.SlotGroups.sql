CREATE TABLE [Techs].[SlotGroups]
(
[SlotGroupName] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocList] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[SlotGroups] ADD CONSTRAINT [PK_SlotGroups] PRIMARY KEY CLUSTERED  ([SlotGroupName]) ON [PRIMARY]
GO
