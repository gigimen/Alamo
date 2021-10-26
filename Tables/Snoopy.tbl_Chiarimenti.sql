CREATE TABLE [Snoopy].[tbl_Chiarimenti]
(
[ChiarimentoID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[AttivitaProf] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProvenienzaPatr] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltreInfo] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColloquioUserAccessID] [int] NULL,
[ColloquioTimeUTC] [datetime] NULL,
[ColloquioGamingDate] [datetime] NULL,
[FormIVTimeLoc] [datetime] NULL,
[FormIVUserAccessID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Chiarimenti] ADD CONSTRAINT [PK_Chiarimenti] PRIMARY KEY CLUSTERED  ([ChiarimentoID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Chiarimenti] WITH NOCHECK ADD CONSTRAINT [FK_Chiarimenti_UserAccesses] FOREIGN KEY ([ColloquioUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
GRANT INSERT ON  [Snoopy].[tbl_Chiarimenti] TO [SolaLetturaNoDanni]
GO
GRANT SELECT ON  [Snoopy].[tbl_Chiarimenti] TO [SolaLetturaNoDanni]
GO
GRANT UPDATE ON  [Snoopy].[tbl_Chiarimenti] TO [SolaLetturaNoDanni]
GO
