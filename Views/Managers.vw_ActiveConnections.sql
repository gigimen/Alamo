SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Managers].[vw_ActiveConnections]
as

SELECT spid,hostname,program_name,login_time,loginame,status,nt_domain,nt_username
FROM
    master.sys.sysprocesses
WHERE 
    DB_NAME(dbid)= 'ALAMO'
GO
