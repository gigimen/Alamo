SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Accounting].[fn_TableCalculateRipristino] (
@denoid			int,
@chi			int,
@initVal 		int = 7,
@moduleVal		int = 1
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @outVal int
	if @initVal is null
		set @outVal = 0 --if no initvalue is defined keep everything in float
	else 
	begin

	--dal file originale di yiulia
	--IF($Q8=0;0;IF(Chiusura!C5-C$157<0;CEILING(-Chiusura!C5+C$157;C$160);0))
		/*IF @chi=0 
			set @outVal = 0
		else */IF @chi - @initVal < 0 --we are below the max value
				set @outVal = CEILING( cast( -@chi + @initVal as float)/ cast(@moduleVal as float) ) * @moduleVal
		else
			set @outVal = 0	
	end
	return @outVal
END



GO
