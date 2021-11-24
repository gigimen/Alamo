SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Managers].[msp_UpdateStatistics]
	-- Add the parameters for the stored procedure here
	@MaxDaysOld int = 0,
	@SamplePercent int  = NULL,
	@SampleType nvarchar(50) = 'PERCENT'  --'ROWS'  
AS
BEGIN
/*
--The other way, is to use the UPDATE STATISTICS command. This command gives much better granularity of control:

-- Update all statistics on a table  

UPDATE STATISTICS Sales.SalesOrderDetail  

   

-- Update a specific index on a table  

UPDATE STATISTICS Sales.SalesOrderDetail IX_SalesOrderDetail  

   

-- Update one column on a table specifying sample size  

UPDATE STATISTICS Production.Product(Products) WITH SAMPLE 50 PERCENT 
Using update statistics can give you the granularity of control to only update the out of date statistics, 
thus having less impact on your production system.

The following script updates all out of date statistics. 
Set the @MaxDaysOld variable to the number of days you will allow the statistics to be out of date by. 
Setting the @SamplePercent variable to null will use the SQL Server default value of 20,000 rows. 
You can also change the sample type to specify rows or percent.
SET @MaxDaysOld = 0  

SET @SamplePercent = NULL --25  

SET @SampleType = 'PERCENT' 
*/   

BEGIN TRY  

    DROP TABLE #OldStats  

END TRY  

BEGIN CATCH SELECT 1 END CATCH  

   

SELECT 

    RowNum = ROW_NUMBER() OVER (ORDER BY ISNULL(STATS_DATE(object_id, st.stats_id),1))  
    ,TableName = OBJECT_SCHEMA_NAME(st.object_id) + '.' + OBJECT_NAME(st.object_id)  
    ,StatName = st.name 
    ,StatDate = ISNULL(STATS_DATE(object_id, st.stats_id),1)  
INTO #OldStats  
FROM sys.stats st WITH (nolock)  
WHERE DATEDIFF(day, ISNULL(STATS_DATE(object_id, st.stats_id),1), GETDATE()) > @MaxDaysOld  
ORDER BY ROW_NUMBER() OVER (ORDER BY ISNULL(STATS_DATE(object_id, st.stats_id),1))  





DECLARE @MaxRecord int 
DECLARE @CurrentRecord int 
DECLARE @TableName nvarchar(255)  
DECLARE @StatName nvarchar(255)  
DECLARE @SQL nvarchar(max)  
DECLARE @SampleSize nvarchar(100)  

   

SELECT @MaxRecord = MAX(RowNum) FROM #OldStats  
SET @CurrentRecord = 1  
SET @SQL = '' 
SET @SampleSize = ISNULL(' WITH SAMPLE ' + CAST(@SamplePercent AS nvarchar(20)) + ' ' + @SampleType,N'')  

   

WHILE @CurrentRecord <= @MaxRecord  
BEGIN 

    SELECT 
        @TableName = os.TableName  
        ,@StatName = os.StatName  
    FROM #OldStats os  
    WHERE RowNum = @CurrentRecord  


    SET @SQL = N'UPDATE STATISTICS ' + @TableName + ' ' + @StatName + @SampleSize  


    --PRINT @SQL  


    EXEC sp_executesql @SQL  

   

    SET @CurrentRecord = @CurrentRecord + 1  

END 
/*After updating the statistics, the execution plans that use these statistics may become invalid. 
Ideally SQL Server should then create a new execution plan. 
Personally, I prefer to help SQL Server out by flushing the cache. 
I would recommend you do the same. Note, this clears the entire procedure cache for the server, not just the database.

-- Clears the procedure cache for the entire server  
*/
DBCC FREEPROCCACHE 
--You should then also update the usage stats. Usage stats are the row counts stored for each index:

-- Update all usage in the database  

DBCC UPDATEUSAGE (0); 
/*
If you are not already doing so, it is highly recommended to leave the default settings of “Auto Update Statistics” 
and “Auto Create Statistics” ON.
*/
BEGIN TRY  

    DROP TABLE #OldStats  

END TRY  

BEGIN CATCH SELECT 1 END CATCH  


set @SQL = N'SELECT 
    RowNum = ROW_NUMBER() OVER (ORDER BY ISNULL(STATS_DATE(object_id, st.stats_id),1))  
    ,TableName = OBJECT_SCHEMA_NAME(st.object_id) + ''.'' + OBJECT_NAME(st.object_id)  
    ,StatName = st.name 
    ,StatDate = ISNULL(STATS_DATE(object_id, st.stats_id),1)  
FROM sys.stats st WITH (nolock)  
ORDER BY ROW_NUMBER() OVER (ORDER BY ISNULL(STATS_DATE(object_id, st.stats_id),1))  '


exec msdb.dbo.[sp_send_dbmail]
	@recipients                 = 'l.menegolo@casinomendrisio.ch', 
	@subject                    = 'Ricalcolo delle statistiche',
	@body                       = 'Statistiche sugli indici ricalcolate
	
	vedi attachment',
	@query						= @SQL,
	@execute_query_database		= N'Alamo',
	@query_attachment_filename  = N'Statistiche sugli indici.txt',
	@attach_query_result_as_file= 1,
	@query_result_width			= 1024,
	@append_query_error			= 1
	

END
GO
