SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_GetGamingLocalDate2] (
@OpenDate as datetime,
@UTCtoLocal as int,
@StockTypeID as int )
RETURNS datetime 
WITH SCHEMABINDING
AS  
BEGIN 
	if @OpenDate is null
		return @OpenDate
/* this is just for testing in the ssql analyzer
declare @openDate smalldatetime
set @openDate = GetUTCDate()
declare @UTCtoLocal int
set @utcToLocal = DATEDIFF (hh , GetUTCDate(),GetDate())
set @StockTypeID = 1
	print 'Now is '
	print @openDate
*/
	DECLARE @GamingDate datetime
	DECLARE @GamingDateChangeLocalHour datetime
	DECLARE @GamingDateChangeUTCHour datetime
	DECLARE @OpenDateUTCHour datetime
	DECLARE @dayBefore datetime
	DECLARE @temp varchar(50)
	DECLARE	@delayed  int
	set @GamingDate = null
	--read change hour from StockTypes table
	--remember it is in local time
	select @temp = ChangeOfGamingDate,@delayed = GamingDateDelayed from CasinoLayout.StockTypes where StockTypeID = @StockTypeID 
	if @temp is null
	begin
/* TEST
		print 'Inavlid stock type provided '
*/
		return (@GamingDate)
	end
/* TEST
	print 'Change of gaming date at ' + @temp
*/
	set @GamingDateChangeLocalHour = CAST(@temp AS smalldatetime)
	--correct from local to UTC time
	set @GamingDateChangeUTCHour = DATEADD(hh,-@UTCtoLocal,@GamingDateChangeLocalHour)
/* TEST
	print 'UTC Change of gaming date at '
	print DATEPART(hh,@GamingDateChangeUTCHour)
*/
	set @temp = CONVERT(varchar,@OpenDate,8)	
	set @OpenDateUTCHour = @temp
	if(@delayed =1)--if the hour is late i.e. it refers to the day before
	begin
		--if the hour has elapsed the gaming date is the same as the open time
		if( DATEPART(hh,@OpenDate) > DATEPART(hh,@GamingDateChangeUTCHour))
			set @GamingDate =  @OpenDate
		else if( DATEPART(hh,@OpenDate) = DATEPART(hh,@GamingDateChangeUTCHour))
		begin
			--check also for minutes
			if( DATEPART(mi,@OpenDate) >= DATEPART(mi,@GamingDateChangeUTCHour))
				set @GamingDate =  @OpenDate
			else --the gaming date is the day before the open time
			begin
				set @dayBefore = DATEADD(dy,-1,@OpenDate)
				set @GamingDate =  @dayBefore
			end
		end
		else --the gaming date is the day before the open time
		begin
			set @dayBefore = DATEADD(dy,-1,@OpenDate)
			set @GamingDate =  @dayBefore
		end
	end
	else
	begin
		--if the hour has not elapsed the gaming date is the same as the open time
		if( DATEPART(hh,@OpenDate) < DATEPART(hh,@GamingDateChangeUTCHour))
			set @GamingDate =  @OpenDate
		else if( DATEPART(hh,@OpenDate) = DATEPART(hh,@GamingDateChangeUTCHour))
		begin
			--check also for minutes
			if( DATEPART(mi,@OpenDate) < DATEPART(mi,@GamingDateChangeUTCHour))
				set @GamingDate =  @OpenDate
			else --the gaming date is the day after the change time
			begin
				set @dayBefore = DATEADD(dy,+1,@OpenDate)
				set @GamingDate =  @dayBefore
			end
		end
		else --the gaming date is the day after the change time
		begin
			set @dayBefore = DATEADD(dy,+1,@OpenDate)
			set @GamingDate =  @dayBefore
		end
	end
	--get rid of hours and minutes which are not neeeded
	set @GamingDate = DATEADD(hh,-DATEPART(hh,@GamingDate),@GamingDate)
	set @GamingDate = DATEADD(mi,-DATEPART(mi,@GamingDate),@GamingDate)
	set @GamingDate = DATEADD(ss,-DATEPART(ss,@GamingDate),@GamingDate)
	set @GamingDate = DATEADD(ms,-DATEPART(ms,@GamingDate),@GamingDate)
/* TEST
	print (@GamingDate)
*/
	return (@GamingDate)
END
GO
