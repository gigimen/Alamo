CREATE TABLE [Yogi].[tbl_ChipMasterControl]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Gamingdate] [datetime] NOT NULL CONSTRAINT [DF_tbl_ChipMasterControl_Gamingdate] DEFAULT ([GeneralPurpose].[fn_GetGamingDate](getdate(),(0),(7))),
[Time] [time] NOT NULL,
[Note] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Tecnico] [int] NOT NULL,
[TavoloId] [int] NOT NULL,
[Totale] [float] NOT NULL,
[ChipId] [int] NOT NULL,
[Dove] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Yogi].[tbl_ChipMasterControl] ADD CONSTRAINT [PK_tbl_ChipMasterControl] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
