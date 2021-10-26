SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_RoundToClosest] (@inVal float,@roundTo float)  
RETURNS float 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @ret int 
	set @ret = 0

	declare @outVal float
	set @outVal = @inVal / @roundTo

	if @outVal >= 0 
	BEGIN
		set @ret = FLOOR (@outVal)
		if ABS(@outVal - @ret - 0.5) < 0.0001  --is equl to 0.05 with a tolerance of 0.0001
			OR @outVal - @ret > 0.5 
			--if we exceed .5 round to ceiling
			set @ret = CEILING (@outVal)

	end
	else
	begin
		set @ret = CEILING (@outVal)
		if @ret - @outVal > 0.5 
			--if we exceed .5 round to floor
			set @ret = floor(@outVal)
	end
	return @ret * @roundTo
END





GO
