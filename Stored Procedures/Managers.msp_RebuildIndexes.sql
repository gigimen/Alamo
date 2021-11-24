SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_RebuildIndexes]
	@MaxIndexCount int = 20,
	@MaxIndexSizeKB int  = 100
AS
BEGIN

DECLARE @db_id SMALLINT
DECLARE @object_id INT
declare @SQL nvarchar(max) 
declare @SQL2 nvarchar(max) 

SET @db_id = DB_ID(N'Alamo')
--select DB_ID(N'Alamo') 

IF @db_id IS NULL
BEGIN
    RAISERROR('Invalid database',1,16)
    RETURN 1
END

set @SQL ='
SELECT	object_name(s.object_id,' + cast (@db_id as nvarchar(16)) + ') as table_name,
		b.name as index_name, 
		s.avg_fragmentation_in_percent,
		fragment_count,
		p.partition_number,
		p.rows as [#Records],
		a.total_pages * 8 as [Reserved(kb)],
		a.used_pages * 8 as [Used(kb)]
FROM sys.dm_db_index_physical_stats('+ cast (@db_id as nvarchar(16)) + ',NULL, NULL, NULL , ''LIMITED'') AS s
    inner JOIN sys.indexes AS b ON s.object_id = b.object_id AND s.index_id = b.index_id
	inner join sys.partitions as p on b.object_id = p.object_id and b.index_id = p.index_id
	inner join sys.allocation_units as a on p.partition_id = a.container_id
where s.avg_fragmentation_in_percent > 30
		and s.index_type_desc !=''HEAP''
		and a.total_pages * 8 > ' + cast (@MaxIndexSizeKB as nvarchar(16)) + ' 
		and s.database_id= ' + cast (@db_id as nvarchar(16)) + '
    order by  s.avg_fragmentation_in_percent desc'

--print @SQL
EXEC sp_executesql @SQL  

declare @body varchar(2048)
set @body = 'Statistiche sugli indici prima del Rebuild

Vedi attachment'

exec msdb.dbo.[sp_send_dbmail]
	@recipients                 = 'lmenegolo@cmendrisio.office.ch', 
	@subject                    = 'Frammentazione degli indici prima del REBUILD',
	@body                       = @body,
	@query						= @SQL,
	@execute_query_database		= N'Alamo',
	@query_attachment_filename  = N'Statistiche sugli indici.txt',
	@attach_query_result_as_file= 1,
	@query_result_width			= 1024,
	@append_query_error			= 1		
	

/*
ALTER INDEX PK_Users ON dbo.Users REBUILD; 
ALTER INDEX PK_StockComposition_Denominations ON dbo.StockComposition_Denominations REBUILD;
DBCC INDEXDEFRAG ('alamo','Users','PK_StockComposition_Denominations')
*/

declare @dbName varchar(100),
@tbName varchar(100),
@idxName varchar(100),
@schName varchar(100),
@idxType varchar(100)

declare 
	@objId int,
	@idxId int,
	@avg int,
	@fraCount int

set @body = 'Rebuild progress:

'

declare index_cursor cursor for
	select top(@MaxIndexCount)
		s.object_id
		,s.index_id
		,s.index_type_desc
		,s.avg_fragmentation_in_percent
		,s.fragment_count
	from sys.dm_db_index_physical_stats(@db_id,null,null,null,'LIMITED')AS s
    inner JOIN sys.indexes AS b ON s.object_id = b.object_id AND s.index_id = b.index_id
	inner join sys.partitions as p on b.object_id = p.object_id and b.index_id = p.index_id
	inner join sys.allocation_units as a on p.partition_id = a.container_id
	where avg_fragmentation_in_percent > 30
		and index_type_desc !='HEAP' 
		and a.total_pages * 8 > @MaxIndexSizeKB --look only for index above this threshold in KBytes
		and database_id=@db_id
	order by avg_fragmentation_in_percent desc
	
Open index_cursor

Fetch Next from index_cursor into @objId,@idxId,@idxType,@avg,@fracount
While @@FETCH_STATUS = 0
Begin
	select	@dbName=db_name(@db_id),
			@tbName=object_name(@objId,@db_id),
			@schName = OBJECT_SCHEMA_NAME (@objId,@db_id)
	
	select	@idxName=name 
	from sys.indexes 
	where object_id=@objId and index_id=@idxId
	
	
	set @SQL2 = 'ALTER INDEX ['+@idxName+'] ON ['+@dbName+'].['+@schName+'].['+@tbName+'] REBUILD WITH 
	( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, 
	SORT_IN_TEMPDB = ON, ONLINE = OFF )'

	If (@objId>0 and @idxId>0)
	Begin
		set @body = @body + '
		Database :'+@dbName+' | Table :'+@schName+'.'+@tbName+' | Index :'+@idxName+' | avg :'+cast(@avg as varchar(10))+' | fra :'+cast(@fracount as varchar(10))+' | STARTED';
		
		EXEC sp_executesql @SQL2  
		
		select 
			@avg		=	s.avg_fragmentation_in_percent,
			@fracount	=	s.fragment_count
		from sys.dm_db_index_physical_stats(@db_id,null,null,null,'LIMITED') s
		where s.database_id=@db_id and s.object_id=@objId and s.index_id=@idxId
		
		
		set @body = @body + '
		Database :'+@dbName+' | Table :'+@schName+'.'+@tbName+' | Index :'+@idxName+' | avg :'+cast(@avg as varchar(10))+' | fra :'+cast(@fracount as varchar(10))+' | COMPLETED
		'
	End
	else
		set @body = @body + '
		No Indexes are available to rebuild'
	Fetch Next from index_cursor into @objId,@idxId,@idxType,@avg,@fraCount
End



exec msdb.dbo.[sp_send_dbmail]
	@recipients                 = 'l.menegolo@casinomendrisio.ch', 
	@subject                    = 'Frammentazione degli indici dopo il REBUILD',
	@body                       = @body,
	@query						= @SQL,
	@execute_query_database		= N'Alamo',
	@query_attachment_filename  = N'Statistiche sugli indici.txt',
	@attach_query_result_as_file= 1,
	@query_result_width			= 1024,
	@append_query_error			= 1
	
close index_cursor
deallocate index_cursor


END
GO
