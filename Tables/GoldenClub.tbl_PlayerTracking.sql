CREATE TABLE [GoldenClub].[tbl_PlayerTracking]
(
[GamingDate] [datetime] NOT NULL,
[CustomerID] [int] NOT NULL,
[PrimoIngresso] [datetime] NULL,
[UltimoIngresso] [datetime] NULL,
[TotIngressi] [int] NULL,
[PrimoEuroIn] [datetime] NULL,
[UltimoEuroIn] [datetime] NULL,
[CountEuroIn] [int] NULL,
[TotEuroInSfr] [float] NULL,
[PrimoEuroOut] [datetime] NULL,
[UltimoEuroOut] [datetime] NULL,
[CountEuroOut] [int] NULL,
[TotEuroOutSfr] [float] NULL,
[PrimaRegIn] [datetime] NULL,
[UltimaRegIn] [datetime] NULL,
[CountRegIn] [int] NULL,
[TotRegInSfr] [int] NULL,
[PrimaRegOut] [datetime] NULL,
[UltimaRegOut] [datetime] NULL,
[CountRegOut] [int] NULL,
[TotRegOutSfr] [int] NULL,
[PrimoAss] [datetime] NULL,
[UltimoAss] [datetime] NULL,
[CountAss] [int] NULL,
[TotAssSfr] [float] NULL,
[PrimoCC] [datetime] NULL,
[UltimoCC] [datetime] NULL,
[CountCC] [int] NULL,
[TotCCSfr] [float] NULL,
[TotPartecipazioniEven] [int] NULL,
[PrimaPartecipazione] [datetime] NULL,
[UltimaPartecipazione] [datetime] NULL,
[Accompagnati] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_PlayerTracking] ADD CONSTRAINT [PK_tbl_PlayerTracking2] PRIMARY KEY CLUSTERED  ([GamingDate], [CustomerID]) ON [PRIMARY]
GO
