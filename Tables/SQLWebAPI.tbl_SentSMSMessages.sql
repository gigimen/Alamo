CREATE TABLE [SQLWebAPI].[tbl_SentSMSMessages]
(
[MsgID] [int] NOT NULL IDENTITY(1, 1),
[recipients] [varchar] (1024) COLLATE Latin1_General_CI_AS NOT NULL,
[messageText] [varchar] (1024) COLLATE Latin1_General_CI_AS NOT NULL,
[TimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_SMSkdevSentMessages_TimeStampUTC] DEFAULT (getutcdate()),
[answer] [varchar] (256) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [SQLWebAPI].[tbl_SentSMSMessages] ADD CONSTRAINT [PK_SMSkdevMsgId] PRIMARY KEY CLUSTERED  ([MsgID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'record all sms sent by this server via SMSkdev', 'SCHEMA', N'SQLWebAPI', 'TABLE', N'tbl_SentSMSMessages', NULL, NULL
GO
