CREATE SCHEMA [CasinoLayout]
AUTHORIZATION [dbo]
GO
GRANT EXECUTE ON SCHEMA:: [CasinoLayout] TO [FloorUsage]
GO
GRANT SELECT ON SCHEMA:: [CasinoLayout] TO [FloorUsage]
GO
GRANT EXECUTE ON SCHEMA:: [CasinoLayout] TO [TecRole]
GO
GRANT SELECT ON SCHEMA:: [CasinoLayout] TO [TecRole]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contiene tutte le definizioni utilizatte per modellare el entita costituenti il sistema Alamo come gli utenti e i loro gruppi, i valori e le denominazioni gestite, i tipi di conteggi e transazioni possibili, gli stock contenenti i valori.', 'SCHEMA', N'CasinoLayout', NULL, NULL, NULL, NULL
GO
