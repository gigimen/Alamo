SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Managers].[vw_AllViewNonSchemaBound]
AS
SELECT SCHEMA_NAME(schema_id) AS schema_name
,name AS view_name
,OBJECTPROPERTYEX(OBJECT_ID,'IsSchemaBound') AS IsSchemaBound
FROM sys.views
WHERE OBJECTPROPERTYEX(OBJECT_ID,'IsSchemaBound') = 0
GO
