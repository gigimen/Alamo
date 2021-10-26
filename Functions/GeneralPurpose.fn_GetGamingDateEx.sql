SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [GeneralPurpose].[fn_GetGamingDateEx] (
@Ora  DATETIME,
@oraIsUTC INT,
@GamingDateChangeLocalHour INT = 9 --let's change the GamingDate at 9 am by default
)
RETURNS DATE 
WITH SCHEMABINDING
AS  
BEGIN 
	IF @Ora IS NULL
		RETURN @Ora
/* this is just for testing in the ssql analyzer
declare @openDate smalldatetime
set @openDate = GetUTCDate()
declare @UTCtoLocal int
set @utcToLocal = DATEDIFF (hh , GetUTCDate(),GetDate())
set @StockTypeID = 1
	print 'Now is '
	print @openDate
*/
	DECLARE @GamingDate DATE
	DECLARE @dayBefore DATE
	SET @GamingDate = NULL


	IF @GamingDateChangeLocalHour = NULL
		SET @GamingDateChangeLocalHour = 9 

	--correct from UTC to localtime
	IF @oraIsUTC = 1
		SET @Ora = GeneralPurpose.fn_UTCToLocal(1,@Ora)

	--if the hour has elapsed the gaming date is the same as @ora
	IF  DATEPART(hh,@Ora) >= @GamingDateChangeLocalHour
	BEGIN
		SET @GamingDate =  @Ora
	END
	ELSE --the gaming date is the day before the open time
	BEGIN
		SET @dayBefore = DATEADD(dy,-1,@Ora)
		SET @GamingDate =  @dayBefore
	END
/* TEST
	print (@GamingDate)
*/
	RETURN (@GamingDate)
END
GO
