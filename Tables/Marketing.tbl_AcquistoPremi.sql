CREATE TABLE [Marketing].[tbl_AcquistoPremi]
(
[AcquistoID] [int] NOT NULL IDENTITY(1, 1),
[CreationTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClubAcquistoPremio_InsertTimeStapUTC] DEFAULT (getutcdate()),
[DummyField] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[tbl_AcquistoPremi] ADD CONSTRAINT [PK_GoldenClubAcquistoPremi] PRIMARY KEY CLUSTERED  ([AcquistoID]) ON [PRIMARY]
GO
