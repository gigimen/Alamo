SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_IsGamingDateToday] 
(
@UTCDate as datetime,
@UTCToday as datetime,
@UTCtoLocal as int,
@StockTypeID as int 
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
/* this is just for testing in the ssql analyzer
declare @openDate smalldatetime
set @openDate = GetUTCDate()
declare @UTCtoLocal int
set @UTCtoLocal = 1
	print 'open date is  ' + convert(varchar,@openDate,108)
*/
	DECLARE @IsToday int
	DECLARE @GamingDateLocal datetime
	set  @GamingDateLocal = GeneralPurpose.fn_GetGamingLocalDate2(
							@UTCToday,
							@UTCtoLocal,
							@StockTypeID)
	
	if(DATEPART(dy,@UTCDate) = DATEPART(dy,@GamingDateLocal))
		set @IsToday = 1
	else
		set @IsToday = 0
	return (@IsToday)
END
GO
