SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Accounting].[fn_TableCalculateConsegna] (
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
	else if @denoid in(1,2,128,129) --placche 10'000 e '5000 sia sfr che €
	begin
	/*
	--dal file originale di yiulia
	--IF($Q15=0;0;IF(RepRip!C$157=0;FLOOR(Chiusura!C12;RepRip!C$160);IF(Chiusura!C12-RepRip!C$157>=0;RepRip!C$154+FLOOR(Chiusura!C12-RepRip!C$157;RepRip!C$160);IF(Chiusura!C12+RepRip!C$154-C$157>=0;FLOOR(Chiusura!C12-C$157+RepRip!C$154;C$160);0))))
			IF @chi=0 
			set @outVal = 0
		else IF @initVal = 0
				set @outVal = FLOOR( cast(@chi as float ) / cast(@moduleVal as float))
		else IF @chi - @initVal >= 0 --we exceeede the max value
				set @outVal = @boo + FLOOR( cast( @chi - @initVal as float)/ cast(@moduleVal as float) )
		else IF @chi + @boo - @initVal >= 0 
				set @outVal = FLOOR( cast(@chi - @initVal + @boo as float) / cast(@moduleVal as float) )
		else
			set @outVal = 0	
			*/

			--fai molto piu semplice: metti in riserva l'eccedenza rispetto il valore iniziale
			if (@chi - @initVal) > 0 --we exceeede the init value
				set @outVal = @chi - @initVal
			else
				set @outVal = 0 
	end
	else
	begin
		--tutte le altre denominazioni vanno nella riserva solo i vassoi interi
		declare @riserva int
		set @riserva = FLOOR( cast(@chi as float ) / cast(@moduleVal as float)) * @moduleVal
		if @riserva > @initVal
			set @outVal = @riserva - @initVal
		else
			set @outVal = 0 
	end
	return @outVal
END



GO
