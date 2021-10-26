CREATE TABLE [Snoopy].[tbl_EntrateSummary]
(
[GamingDate] [datetime] NOT NULL,
[Entrances] [int] NOT NULL,
[GoldenClub] [int] NOT NULL,
[GoldenClubUno] [int] NOT NULL,
[Membri] [int] NOT NULL,
[MembriUno] [int] NOT NULL,
[CambiEuroRedeemableCount] [int] NULL,
[CambiEuroRedeeemableTot] [int] NULL,
[Visite] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_EntrateSummary] ADD CONSTRAINT [PK_CK_Entrances] PRIMARY KEY CLUSTERED  ([GamingDate]) ON [PRIMARY]
GO
