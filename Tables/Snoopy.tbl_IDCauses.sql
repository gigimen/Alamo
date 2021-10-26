CREATE TABLE [Snoopy].[tbl_IDCauses]
(
[IdCauseID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DenoID] [int] NULL,
[ForCassa] [bit] NULL,
[ForSnoopy] [bit] NULL,
[IdentificationLimit] [int] NULL,
[RegistrationLimit] [int] NULL,
[ChiarimentoLimit] [int] NULL,
[Direction] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectorID] [int] NULL,
[PepCheckLimit] [int] NULL,
[GoldenClubMemberTypeID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_IDCauses] ADD CONSTRAINT [PK_IDCauses] PRIMARY KEY CLUSTERED  ([IdCauseID]) ON [PRIMARY]
GO
