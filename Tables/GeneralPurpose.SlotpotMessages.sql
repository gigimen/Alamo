CREATE TABLE [GeneralPurpose].[SlotpotMessages]
(
[JpID] [int] NOT NULL,
[Msg] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GeneralPurpose].[SlotpotMessages] ADD CONSTRAINT [CK_SlotpotMessages] CHECK (([JpID]=(74) OR [JpID]=(73) OR [JpID]=(72) OR [JpID]=(71) OR [JpID]=(70)))
GO
