CREATE TABLE [Snoopy].[tbl_Uscite]
(
[TimestampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_Uscite_TimestampUTC] DEFAULT (getutcdate()),
[SiteID] [int] NOT NULL,
[TimestampLoc] [datetime] NOT NULL CONSTRAINT [DF_tbl_Uscite_TimestampLoc] DEFAULT (getdate()),
[GamingDate] [datetime] NOT NULL CONSTRAINT [DF_tbl_Uscite_GamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingLocalDate2](getdate(),(0),(22))),
[Increment] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Uscite] ADD CONSTRAINT [CK_tbl_Uscite] CHECK (([Increment]=(1) OR [Increment]=((-1))))
GO
ALTER TABLE [Snoopy].[tbl_Uscite] ADD CONSTRAINT [PK_tbl_Uscite] PRIMARY KEY CLUSTERED  ([TimestampUTC], [SiteID]) ON [PRIMARY]
GO
GRANT INSERT ON  [Snoopy].[tbl_Uscite] TO [rasSesam3]
GO
GRANT SELECT ON  [Snoopy].[tbl_Uscite] TO [rasSesam3]
GO
