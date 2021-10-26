CREATE TABLE [SQLWebAPI].[tbl_DOSGroupAPILogger]
(
[PK_ID] [int] NOT NULL IDENTITY(1, 1),
[API] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[CardId] [int] NOT NULL,
[GamingDate] [datetime] NOT NULL CONSTRAINT [DF_tbl_DOSGroupAddPointLogger_GamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingDate](getutcdate(),(1),DEFAULT)),
[TimestampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_DOSGroupAddPointLogger_TimestampUTC] DEFAULT (getutcdate()),
[RetCodeDescription] [nvarchar] (max) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [SQLWebAPI].[tbl_DOSGroupAPILogger] ADD CONSTRAINT [PK_SQLWebAPI_DOSGroupAddPointLogger] PRIMARY KEY CLUSTERED  ([PK_ID]) ON [PRIMARY]
GO
