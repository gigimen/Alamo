SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Luigi Menegolo
-- Create date: 07-11-2013
-- Description:	backups the database with the correct name
-- =============================================

CREATE PROC [Managers].[msp_BackupDbWithTs]
@folder NVARCHAR(255)
,@backup_type VARCHAR(13)
,@backup_extension VARCHAR(10)
,@do_overwrite CHAR(1) = 'N'
,@with_checksum CHAR(1) = 'Y'
,@do_verification CHAR(1) = 'Y'
AS
DECLARE @db_name SYSNAME
DECLARE @sql NVARCHAR(4000)
DECLARE @filename NVARCHAR(255)
DECLARE @bkpname NVARCHAR(255)
DECLARE @full_path_and_filename NVARCHAR(1000)
DECLARE @err_msg NVARCHAR(2000)
DECLARE @crlf VARCHAR(2)
DECLARE @GamingDate DATE

SELECT @GamingDate = [GeneralPurpose].[fn_GetGamingDate] (GETDATE(),0,7)

SET @crlf = CHAR(13) + CHAR(10)

SET @db_name = 'Alamo'
--Verify valid backup type
IF @backup_type = 'DATABASE'
	SET @bkpname = 'Alamo full backup'
ELSE IF  @backup_type = 'DIFFERENTIAL'
	SET @bkpname = 'Alamo differential backup'
ELSE IF @backup_type = 'LOG'
	set @bkpname = 'Alamo transaction log backup at ' + CONVERT(NVARCHAR(16), CURRENT_TIMESTAMP, 108)
ELSE
BEGIN
	SET @err_msg = 'Backup type ' + @backup_type + ' is not valid.
	Allowed values are DATABASE, LOG and DIFFERENTIAL'
	RAISERROR(@err_msg, 16, 1)
	RETURN -101
END

--PRINT @bkpname

--Make sure folder name ends with '\'
IF RIGHT(@folder, 1) <> '\'
SET @folder = @folder + '\'

--Make file extension starts with '.'
IF LEFT(@backup_extension, 1) <> '.'
SET @backup_extension = '.' + @backup_extension

--Construct filename  
/*
PRINT CONVERT(VARCHAR(16), CURRENT_TIMESTAMP, 108)
--PRINT REPLACE(CONVERT(CHAR(16), CURRENT_TIMESTAMP, 120), '-', '')
PRINT REPLACE(CONVERT(CHAR(16), CURRENT_TIMESTAMP, 120), ' ', '-')
PRINT REPLACE(REPLACE(CONVERT(CHAR(16), CURRENT_TIMESTAMP, 120), ' ', '-'), ':', 'h-') + 'm'

SELECT CONVERT (date, SYSDATETIME())
    ,CONVERT (date, SYSDATETIMEOFFSET())
    ,CONVERT (date, SYSUTCDATETIME())
    ,CONVERT (date, CURRENT_TIMESTAMP)
    ,CONVERT (date, GETDATE())
    ,CONVERT (date, GETUTCDATE());
*/
SET @filename = @db_name + '_backup_' + CONVERT(varCHAR(16), CONVERT (date, @GamingDate),120)--+ REPLACE(REPLACE(CONVERT(CHAR(16), CURRENT_TIMESTAMP, 120), ' ', '-'), ':', 'h-') + 'm'
--Construct full path and file name  
SET @full_path_and_filename = @folder + @filename + @backup_extension

--Construct backup command  
SET @sql = 'BACKUP ' + CASE @backup_type WHEN 'LOG' THEN 'LOG' ELSE 'DATABASE' END + ' ' + QUOTENAME(@db_name) + @crlf
SET @sql = @sql + 'TO DISK = ' + QUOTENAME(@full_path_and_filename,'''') + @crlf 
SET @sql = @sql + 'WITH' + @crlf
SET @sql = @sql + CASE @do_overwrite WHEN 'N' THEN ' NOINIT,' ELSE ' INIT,' END + @crlf
SET @sql = @sql + ' NAME = ' + QUOTENAME(@bkpname,'''') + ',' + @crlf

IF @backup_type = 'DIFFERENTIAL'
	SET @sql = @sql + ' DIFFERENTIAL,' + @crlf

IF @with_checksum <> 'N'
	SET @sql = @sql + ' CHECKSUM,' + @crlf

--Add backup option below if you want to!!!
	SET @sql = @sql + ' SKIP, ' + @crlf
	SET @sql = @sql + ' NO_COMPRESSION ' + @crlf

--Remove trailing comma and CRLF
SET @sql = LEFT(@sql, LEN(@sql) - 3)

--PRINT @sql
EXEC master.sys.sp_executesql @sql

IF @do_verification = 'Y'
	RESTORE VERIFYONLY FROM DISK = @full_path_and_filename
GO
