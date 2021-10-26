SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [GeneralPurpose].[fn_GetDates]
(
      -- Add the parameters for the function here
      @DtFrom DATETIME,
      @DtTo DATETIME
)

RETURNS @DateList TABLE (
	Dt DATETIME,
	PRIMARY KEY CLUSTERED 
(
	Dt ASC
))
WITH SCHEMABINDING
AS
BEGIN

--

/*


select Dt from [GeneralPurpose].[fn_GetDates] ('3.1.2020','3.31.2020')


*/
      DECLARE @TotDays INT
      DECLARE @CNT INT

      SET @TotDays =  DATEDIFF(DD,@DtFrom,@DtTo)-- [NO OF DAYS between two dates]

      SET @CNT = 0
      WHILE @TotDays >= @CNT        -- repeat for all days 
      BEGIN
        -- Pick each single day and check for the day needed
            INSERT INTO @DateList
            SELECT (@DtTo - @CNT) AS DAT
            SET @CNT = @CNT + 1
      END
      RETURN
END
GO
