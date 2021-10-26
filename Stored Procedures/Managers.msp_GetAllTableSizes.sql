SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Managers].[msp_GetAllTableSizes]
AS
/*
    Obtains spaced used data for ALL user tables in the database
*/
-- Table row counts and sizes.
CREATE TABLE #t 
( 
    [name] NVARCHAR(128),
    [rows] CHAR(11),
    reserved VARCHAR(18), 
    data VARCHAR(18), 
    index_size VARCHAR(18),
    unused VARCHAR(18)
) 

INSERT #t EXEC master.[sys].[sp_MSforeachtable] 'EXEC sp_spaceused ''?''' 
DECLARE @totSize INT
SELECT @totSize = SUM(CAST( LEFT(data,LEN(data) -3 ) AS INT)) FROM   #t

SELECT 
    [name] AS TableName,
    [rows],
    reserved AS ReservedSize, 
    data AS DataSize, 
--	cast( left(data,len(data) -3 ) as int) as DataSizeKB,
    index_size,
    unused,
	@totSize AS 'Total Database DataSize KB',
	CASE WHEN @totSize > 0 then CAST( LEFT(data,LEN(data) -3 ) AS FLOAT) / @totSize * 100 ELSE 0 end AS Percentage
FROM   #t
ORDER BY CASE WHEN @totSize > 0 then CAST( LEFT(data,LEN(data) -3 ) AS FLOAT) / @totSize * 100 ELSE 0 end DESC


SELECT SUM(CAST( LEFT(data,LEN(data) -3 ) AS INT)) AS TotDataSize,
SUM(CAST( LEFT(reserved,LEN(reserved) -3 ) AS INT)) AS TotReservedSize,
SUM(CAST( LEFT(index_size,LEN(index_size) -3 ) AS INT)) AS TotIndexSize,
SUM(CAST( LEFT(unused,LEN(unused) -3 ) AS INT)) AS TotUnusedSize
FROM   #t

DROP TABLE #t
GO
