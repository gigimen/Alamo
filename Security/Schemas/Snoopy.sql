CREATE SCHEMA [Snoopy]
AUTHORIZATION [dbo]
GO
GRANT EXECUTE ON SCHEMA:: [Snoopy] TO [FloorUsage]
GO
GRANT SELECT ON SCHEMA:: [Snoopy] TO [FloorUsage]
GO
GRANT SELECT ON SCHEMA:: [Snoopy] TO [GoldenClubUsage]
GO
GRANT EXECUTE ON SCHEMA:: [Snoopy] TO [LRDManagement]
GO
GRANT INSERT ON SCHEMA:: [Snoopy] TO [LRDManagement]
GO
GRANT SELECT ON SCHEMA:: [Snoopy] TO [LRDManagement]
GO
GRANT UPDATE ON SCHEMA:: [Snoopy] TO [LRDManagement]
GO
GRANT SELECT ON SCHEMA:: [Snoopy] TO [TecRole]
GO
