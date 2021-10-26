CREATE TABLE [Marketing].[tbl_AssegnazionePremi]
(
[AssegnazionePremioID] [int] NOT NULL IDENTITY(1, 1),
[OffertaPremioID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClubAssegnazionePremi_InsertTimeStampUTC] DEFAULT (getutcdate()),
[RitiratoTimeStampUTC] [datetime] NULL,
[InsertSiteID] [int] NOT NULL,
[RitiroSiteID] [int] NULL,
[AcquistoID] [int] NULL,
[SmsInviatoTimeStampUTC] [datetime] NULL,
[InsertUserID] [int] NULL CONSTRAINT [DF_tbl_AssegnazionePremi_InsertUserID] DEFAULT ((1)),
[Multiplo] [int] NULL,
[AssigningSectorID] [int] NULL,
[CancelTimeUTC] [datetime] NULL,
[RitiratoGamingDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_AssegnazionePremi] ADD CONSTRAINT [PK_GoldenClubAssegnazionePremi] PRIMARY KEY CLUSTERED  ([AssegnazionePremioID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbl_AssegnazionePremi_RitiroGamingDate] ON [Marketing].[tbl_AssegnazionePremi] ([RitiratoGamingDate], [CustomerID]) ON [PRIMARY]
GO
