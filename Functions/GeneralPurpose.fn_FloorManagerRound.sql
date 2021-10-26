SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_FloorManagerRound] (@val float)  
RETURNS INT 
WITH SCHEMABINDING 
AS 
BEGIN 
declare @ret int 
	set @ret = 0
	if @val >= 0 
	begin
		set @ret = FLOOR (@val)
		if @val - @ret >= 0.5 
			--if we exceed .5 round to ceiling
			set @ret = CEILING (@val)
	end
	else
	begin
		set @ret = CEILING (@val)
		if @ret - @val > 0.5 
			--if we exceed .5 round to floor
			set @ret = floor(@val)
	end
	return @ret
END




GO
