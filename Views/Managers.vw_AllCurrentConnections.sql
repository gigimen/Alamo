SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Managers].[vw_AllCurrentConnections]
AS

SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections
    ,loginame as LoginName
FROM
    master.sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame

GO
