SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [Accounting].[usp_DeleteAllInconsistentSoftCounts]
@currDrop	INT,
@tOraUTC	DATETIME,
@lfid		INT
AS
if @tOraUTC is null
	set @tOraUTC = GETUTCDATE()

declare @ret int
set @ret = CURSOR_STATUS ('global','softcount_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar) 
if @ret > -3
begin
--	print 'deallocting 'softcount_cursor''
	DEALLOCATE softcount_cursor
end

BEGIN TRY
	DECLARE softcount_cursor CURSOR
	   FOR
		select StockID,StateTimeUTC from Accounting.vw_AllProgress 
				where LifeCycleID = @lfid
				and DenoID = 11 --Denomination for soft count drop
				and (
					( Quantity > @currDrop and StateTimeUTC < @tOraUTC) or
					( Quantity < @currDrop and StateTimeUTC > @tOraUTC)
					)
	OPEN softcount_cursor

	declare @stateTimeUTC datetime
	declare @dummy datetime
	declare @StockID int
	FETCH NEXT FROM softcount_cursor INTO @StockID,@stateTimeUTC
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		print 'Deleteing Progress LifeCycleID=''' + cast(@lfid as varchar(16)) + ''' ' +
				'TransTimeUTC='''+ convert(varchar(16),@stateTimeUTC,113 )  
		execute @ret = Accounting.usp_DeleteLifeCycleProgress @lfid,11,@stateTimeUTC,@dummy output
	
		FETCH NEXT FROM softcount_cursor INTO @StockID,@stateTimeUTC
	END
END TRY  
BEGIN CATCH  
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

set @ret = CURSOR_STATUS ('global','softcount_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar) 
if @ret > -3
begin
--	print 'deallocting 'softcount_cursor''
	DEALLOCATE softcount_cursor
end


return @ret
GO
