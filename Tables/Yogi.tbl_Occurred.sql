CREATE TABLE [Yogi].[tbl_Occurred]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FK_CustomerID] [int] NOT NULL,
[FK_UserID] [int] NOT NULL,
[GamingDate] [smalldatetime] NOT NULL,
[Descrizione] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[osservazione] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[TimestampUTC] [datetime] NOT NULL,
[ActionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Yogi].[tbl_Occurred] ADD CONSTRAINT [PK_Occurred] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [Yogi].[tbl_Occurred] ADD CONSTRAINT [FK_tbl_Occurred_tbl_Customers] FOREIGN KEY ([FK_CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Yogi].[tbl_Occurred] ADD CONSTRAINT [FK_tbl_Occurred_Users] FOREIGN KEY ([FK_UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
