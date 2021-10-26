CREATE TABLE [GoldenClub].[tbl_InvitoEventi]
(
[EventoID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[SMSNotificationReceivedTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClubInvitoEventi_SMSNotificationReceivedTimeStampUTC] DEFAULT (getutcdate()),
[SMSAnswer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivered] [smallint] NOT NULL,
[Recipient] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_InvitoEventi] ON [GoldenClub].[tbl_InvitoEventi] ([EventoID], [CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_InvitoEventi] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubInvitoEventi_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [GoldenClub].[tbl_InvitoEventi] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubInvitoEventi_GoldenClubEventiMarketing] FOREIGN KEY ([EventoID]) REFERENCES [Marketing].[tbl_Eventi] ([EventoID])
GO
