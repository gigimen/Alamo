SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_StockCalculateRipristino] (
@denoid			int,
@chi			int,
@initVal 		int = 0,
@moduleVal		int = 1,
@tipoRipristino	int = 1 -- 1=tavoli,2=casse,3=euro casse
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @ripristino int

	if @tipoRipristino = 1
	begin

	/*
		QUESTO E' il tipico ripristino dei tavoli dove si tengono gli sciolti nel float e si consegnano le eccedenze in moduli
		In pratica lo stock non è riprisitnato ad un set fisso di valori 
	*/
		if @initVal is null
			set @ripristino = 0 --if no initvalue is defined keep everything in float
		else 
		begin

		--dal file originale di yiulia
		--IF($Q8=0;0;IF(Chiusura!C5-C$157<0;CEILING(-Chiusura!C5+C$157;C$160);0))
			IF @chi=0 
				--ho finito con niente ripristimami al valore iniziale
				set @ripristino = @initVal
			else IF @chi - @initVal < 0 --we are below the max value
					set @ripristino = CEILING( cast( -@chi + @initVal as float)/ cast(@moduleVal as float) ) * @moduleVal
			else
				set @ripristino = 0	
		end
	end
	else
	begin
	/*
		QUESTO E' il tipico ripristino delle casse dove si tengono gli sciolti nel float e si consegnano le eccedenze in moduli
		In 
	*/
		set @ripristino = 0	
	end
	return @ripristino
END




GO
