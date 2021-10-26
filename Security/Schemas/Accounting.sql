CREATE SCHEMA [Accounting]
AUTHORIZATION [dbo]
GO
GRANT EXECUTE ON SCHEMA:: [Accounting] TO [FloorUsage]
GO
GRANT INSERT ON SCHEMA:: [Accounting] TO [FloorUsage]
GO
GRANT SELECT ON SCHEMA:: [Accounting] TO [FloorUsage]
GO
GRANT UPDATE ON SCHEMA:: [Accounting] TO [FloorUsage]
GO
GRANT SELECT ON SCHEMA:: [Accounting] TO [SolaLetturaNoDanni]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transazioni, Snapshots progressivi degli stock', 'SCHEMA', N'Accounting', NULL, NULL, NULL, NULL
GO
