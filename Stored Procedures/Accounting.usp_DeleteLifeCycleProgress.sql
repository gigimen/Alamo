SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  procedure [Accounting].[usp_DeleteLifeCycleProgress]
@lfCyID int,
@DenoID int,
@statetimeUTC datetime,
@statetimeLoc datetime output
AS
if not exists (
	select LifeCycleID
	from Accounting.tbl_Progress 
	where 
		DenoID=@DenoID AND 
		StateTime = @statetimeUTC AND 
		LifeCycleID = @lfCyID
  )
begin
	declare @l varchar(64)
	set @l = convert(varchar(24),@statetimeUTC,113)
	raiserror('The progress in not present at hour %s',16,1,@l)
	return 2
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteLifeCycleProgress

BEGIN TRY  


	--delet first all modifications on this data
	delete FloorActivity.tbl_ProgressModifications 
		where 
		DenoID=@DenoID AND 
		StateTime = @statetimeUTC AND 
		LifeCycleID = @lfCyID

	delete Accounting.tbl_Progress 
		where 
		DenoID=@DenoID AND 
		StateTime = @statetimeUTC AND 
		LifeCycleID = @lfCyID

	commit transaction  trn_DeleteLifeCycleProgress
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteLifeCycleProgress		
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret
END CATCH

set @statetimeLoc = GeneralPurpose.fn_UTCToLocal(1,@statetimeUTC)


/*	--broadcast a message of deletion of the progress value 
	CString payload;
	payload.Format(
		MSG_ATTR_LFCYID"='%d' "
		MSG_ATTR_STOCKID"='%d' "
		MSG_ATTR_DENOID"='%d' "
		MSG_ATTR_ORA"='%d'",
		lfid.m_nLFID,
		lfid.m_nStockID,
		DenoID,
		stateTime.GetHour());
*/
declare @attr varchar(1024)	
select @attr = 'LifeCycleID=''' + cast(LifeCycleID as varchar(16)) + ''' ' +
		    'StockID=''' 	 + cast(StockID as varchar(16)) + ''' ' +
		    'StockTypeID=''' 	 + cast(StockTypeID as varchar(16)) + ''' ' +
		    'Tag=''' 	 + Tag + ''' ' +
			'GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](GamingDate) + ''' ' +			
		    'DenoID = '''    + cast(@DenoID as varchar(16)) + ''' ' +
		    'TransTimeUTC='''+ cast(DatePArt(hh,@stateTimeUTC) as varchar(16))  + ''' ' +
		    'TransTimeLoc='''+ cast(DatePArt(hh,@stateTimeLOC) as varchar(16))  + ''''
from Accounting.vw_AllStockLifeCycles 
where LifeCycleID = @lfCyID
	
execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteProgress',@attr

return 0
GO
