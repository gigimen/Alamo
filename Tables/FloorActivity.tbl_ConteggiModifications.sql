CREATE TABLE [FloorActivity].[tbl_ConteggiModifications]
(
[ModID] [int] NOT NULL IDENTITY(1, 1),
[UserAccessID] [int] NOT NULL,
[ModDate] [datetime] NOT NULL CONSTRAINT [DF_tbl_ConteggiModifications_ModDate] DEFAULT (getutcdate()),
[ConteggioID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_ConteggiModifications] ADD CONSTRAINT [PK_tbl_ConteggiModifications] PRIMARY KEY CLUSTERED  ([ModID]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_ConteggiModifications] ADD CONSTRAINT [FK_tbl_ConteggiModifications_tbl_Conteggi] FOREIGN KEY ([ConteggioID]) REFERENCES [Accounting].[tbl_Conteggi] ([ConteggioID])
GO
ALTER TABLE [FloorActivity].[tbl_ConteggiModifications] ADD CONSTRAINT [FK_tbl_ConteggiModifications_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
