CREATE TABLE [CasinoLayout].[tbl_ValueTypes]
(
[ValueTypeID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyID] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_ValueTypes] ADD CONSTRAINT [PK_tbl_ValueTypes] PRIMARY KEY CLUSTERED  ([ValueTypeID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contiene le definizioni dei tipi di valori monetizzabili e non gestiti da Alamo cio di tutto cio che rappresnta un valore fisico o un suo controvalore convertibile in valore fisico. Distinguiamo qui i gettoni di valore per gioco ai tavoli, le monete le banconote, assegni carte di credito. Sono definite da un nome una descrizione e da una currency (FK dalla tabella tbl_Currencies)', 'SCHEMA', N'CasinoLayout', 'TABLE', N'tbl_ValueTypes', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Acronim (ex. USD) valid only for foreign currencies', 'SCHEMA', N'CasinoLayout', 'TABLE', N'tbl_ValueTypes', 'COLUMN', N'CurrencyID'
GO
