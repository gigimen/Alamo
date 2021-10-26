CREATE TABLE [CasinoLayout].[tbl_Denominations]
(
[DenoID] [int] NOT NULL IDENTITY(1, 1),
[ValueTypeID] [int] NOT NULL,
[Denomination] [float] NOT NULL,
[IsFisical] [bit] NOT NULL,
[FName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoNotDisplayQuantity] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_Denominations] ADD CONSTRAINT [PK_tbl_Denominations] PRIMARY KEY CLUSTERED  ([DenoID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_Denominations] ADD CONSTRAINT [FK_Denominations_ValueTypes] FOREIGN KEY ([ValueTypeID]) REFERENCES [CasinoLayout].[tbl_ValueTypes] ([ValueTypeID])
GO
ALTER TABLE [CasinoLayout].[tbl_Denominations] ADD CONSTRAINT [FK_tbl_Denominations_tbl_ValueTypes] FOREIGN KEY ([ValueTypeID]) REFERENCES [CasinoLayout].[tbl_ValueTypes] ([ValueTypeID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contiene le definizioni delle singole denominazioni dei tipi di valori monetizzabili e non gestiti da Alamo. Sono definite da un nome una descrizione e da un tipo di valore  (FK dalla tabella tbl_ValueTypes) e dalla denomination che puo essere centesimale e anche negativa. Un flg server a distinguere le denomizioni fisiche (corrispondenti cioe a valori effettivi al portatore come monete banconote e gettoni) da quelle non fisiche (cioe no direttamtne monetizzabili come gli assegni, i ticket le cashless, carte di credito ecc.)', 'SCHEMA', N'CasinoLayout', 'TABLE', N'tbl_Denominations', NULL, NULL
GO
