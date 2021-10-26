SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_TableCalculateChiusuraRiserva] (
@denoid			int,
@chi			int,
@initVal 		int = 7,
@moduleVal		int = 1/*,
@boo			int = 0*/
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @riserva int
	if @initVal is null
		set @riserva = 0 --if no initvalue is defined keep everything in float
	else if @denoid in(1,2,128,129) --placche 10'000 e '5000 sia sfr che €
	begin
	/*
	--dal file originale di yiulia
	--IF($Q15=0;0;IF(RepRip!C$157=0;FLOOR(Chiusura!C12;RepRip!C$160);IF(Chiusura!C12-RepRip!C$157>=0;RepRip!C$154+FLOOR(Chiusura!C12-RepRip!C$157;RepRip!C$160);IF(Chiusura!C12+RepRip!C$154-C$157>=0;FLOOR(Chiusura!C12-C$157+RepRip!C$154;C$160);0))))
			IF @chi=0 
			set @riserva = 0
		else IF @initVal = 0
				set @riserva = FLOOR( cast(@chi as float ) / cast(@moduleVal as float))
		else IF @chi - @initVal >= 0 --we exceeede the max value
				set @riserva = @boo + FLOOR( cast( @chi - @initVal as float)/ cast(@moduleVal as float) )
		else IF @chi + @boo - @initVal >= 0 
				set @riserva = FLOOR( cast(@chi - @initVal + @boo as float) / cast(@moduleVal as float) )
		else
			set @riserva = 0	
			*/

			--fai molto piu semplice: metti in riserva l'eccedenza rispetto il valore iniziale
			if (@chi - @initVal) > 0 --we exceeede the init value
				set @riserva = @chi - @initVal
			else
				set @riserva = 0 
	end
	else
		--tutte le altre denominazioni vanno nella riserva solo i vassoi interi
			set @riserva = FLOOR( cast(@chi as float ) / cast(@moduleVal as float)) * @moduleVal

	return @riserva
END




GO
