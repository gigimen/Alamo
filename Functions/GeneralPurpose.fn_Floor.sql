SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_Floor] (@inVal float,@roundTo float)  
RETURNS float 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @outVal float
	--trucco perchè talvolta sbaglia di una unità se  @inVal è esattamente multiplo di @roundTo
	set @outVal = (@inVal * 100 ) / (@roundTo * 100)
	set  @outVal = FLOOR (@outVal) 
	set @outVal = @outVal * @roundTo
	return (@outVal)

	/*
	declare @outVal float,@inVal float,@roundTo float
	set @inVal = 1211.05 
	set @roundTo = 0.05
	set @outVal = (@inVal ) / (@roundTo)
	--set @outVal = (@inVal * 100 ) / (@roundTo * 100)
	print @outVal
	--usare ROUND perchè FLOOR mi sbaglia il calcolo [fn_Floor] (1211.05 ,0.05)   
	--set @outVal = ROUND (@outVal,0) 
	set  @outVal = FLOOR (@outVal) 
	print @outVal
	set @outVal = @outVal * @roundTo
	print @outVal
	*/
END
GO
