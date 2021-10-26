SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_Ceil] (@inVal float,@roundTo float)  
RETURNS float 
WITH SCHEMABINDING
AS  
BEGIN 
declare @outVal float
	set @outVal = @inVal / @roundTo
	set @outVal = CEILING (@outVal) 
	set @outVal = @outVal * @roundTo
	return (@outVal)
END





GO
