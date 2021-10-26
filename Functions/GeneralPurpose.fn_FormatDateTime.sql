SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [GeneralPurpose].[fn_FormatDateTime]
(
@inputDate datetime
)

returns varchar(20) as
begin
declare @returnValue varchar(25)

SELECT @returnValue = 
      RIGHT('00'   + CAST(DATEPART(day,    @inputDate) AS varchar(2)),2) + '-' +
      RIGHT('00'   + CAST(DATEPART(month,  @inputDate) AS varchar(2)),2) + '-' +
      RIGHT('0000' + CAST(DATEPART(year,   @inputDate) AS varchar(4)),4) + ' ' +
      RIGHT('00'   + CAST(DATEPART(hour,   @inputDate) AS varchar(2)),2) + ':' +
      RIGHT('00'   + CAST(DATEPART(minute, @inputDate) AS varchar(2)),2) --+ ':' +
      --RIGHT('00'   + CAST(DATEPART(second, GETDATE()) AS varchar(2)),2)
-- Return the formated value
return @returnValue
end

GO
