SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_GetGamingDate] (
@Ora  datetime,
@oraIsUTC INT,
@GamingDateChangeLocalHour INT = 9 --let's change the GamingDate at 9 am by default
)
RETURNS datetime 
WITH SCHEMABINDING
AS  
BEGIN 
	if @Ora is null
		return @Ora
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
	DECLARE @dayBefore datetime
	set @GamingDate = null


	IF @GamingDateChangeLocalHour = null
		set @GamingDateChangeLocalHour = 9 

	--correct from UTC to localtime
	if @oraIsUTC = 1
		set @Ora = GeneralPurpose.fn_UTCToLocal(1,@Ora)

	--if the hour has elapsed the gaming date is the same as @ora
	if  DATEPART(hh,@Ora) >= @GamingDateChangeLocalHour
	begin
		set @GamingDate =  @Ora
	end
	else --the gaming date is the day before the open time
	begin
		set @dayBefore = DATEADD(dy,-1,@Ora)
		set @GamingDate =  @dayBefore
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
