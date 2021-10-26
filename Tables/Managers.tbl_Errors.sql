CREATE TABLE [Managers].[tbl_Errors]
(
[ErrorID] [int] NOT NULL IDENTITY(1, 1),
[Dove] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GamingDate] [datetime] NOT NULL CONSTRAINT [DF_tbl_Errors_GamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingDate](getutcdate(),(1),DEFAULT)),
[TimestampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_Errors_TimestampUTC] DEFAULT (getutcdate()),
[HostName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tbl_Errors_HostName] DEFAULT (host_name()),
[ErrDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tbl_Errors_ErrDescription] DEFAULT (error_message()),
[LoggedInUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tbl_Errors_LoggedInUser] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [Managers].[tbl_Errors] ADD CONSTRAINT [PK_Managers_Errors] PRIMARY KEY CLUSTERED  ([ErrorID]) ON [PRIMARY]
GO
GRANT INSERT ON  [Managers].[tbl_Errors] TO [CKeyUsage]
GO
GRANT INSERT ON  [Managers].[tbl_Errors] TO [FloorUsage]
GO
GRANT INSERT ON  [Managers].[tbl_Errors] TO [GoldenClubUsage]
GO
GRANT INSERT ON  [Managers].[tbl_Errors] TO [LRDManagement]
GO
GRANT INSERT ON  [Managers].[tbl_Errors] TO [TecRole]
GO
