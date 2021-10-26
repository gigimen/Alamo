SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Managers].[vw_CasseAttive]
as
SELECT 
    login_time,hostname
FROM
    master.sys.sysprocesses
WHERE 
    DB_NAME(dbid)= 'ALAMO' AND loginame LIKE '%cassa%'
GO
