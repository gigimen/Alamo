SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Managers].[msp_RecreateView]
@viewName NVARCHAR(65),
@schemaName  NVARCHAR(65)
AS
DECLARE @sqlDrop NVARCHAR(MAX)
DECLARE @sqlCreate NVARCHAR(MAX)

DECLARE @fullViewName varchar(80)
SET @fullViewName = @schemaName + '.' + @viewName

IF NOT EXISTS(SELECT [definition] FROM sys.sql_modules WHERE [object_id] = OBJECT_ID(@fullViewName) )
BEGIN
	raiserror('View %s does not exists in database',16,1,@fullViewName)

	return 1
END

SET @sqlDrop = 'DROP VIEW ' + @fullViewName

PRINT @sqlDrop

SELECT @sqlCreate = REPLACE([definition],@fullViewName,@fullViewName + '
WITH SCHEMABINDING')   
FROM sys.sql_modules 
WHERE [object_id] = OBJECT_ID(@fullViewName); 

PRINT @sqlCreate
/*
EXECUTE sys.sp_executesql @sqlDrop
EXECUTE sys.sp_executesql @sqlCreate
*/
GO
