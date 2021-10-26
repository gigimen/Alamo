SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Accounting].[fn_StockCalculateConsegna] (
@DenoID			int,
@chi			int,
@initVal 		int = 0,
@moduleVal		int = 1,
@tipoRipristino	int = 1 -- 1=tavoli,2=casse,3=euro casse
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @Consegna int

	if @tipoRipristino = 1
	begin

	/*
		QUESTO E' il tipico ripristino dei tavoli dove si tengono gli sciolti nel float e si consegnano le eccedenze in moduli
		In pratica lo stock non è riprisitnato ad un set fisso di valori 
	*/

		if @initVal is NULL OR @initVal = 0
--			set @Consegna = 0 --if no initvalue is defined keep everything in float
			set @Consegna = @chi --if no initvalue is defined cosegna everything
		else
		begin
			--vanno nella Consegna solo i vassoi interi
			declare @riserva int
			set @riserva = FLOOR( cast(@chi as float ) / cast(@moduleVal as float)) * @moduleVal

			if @riserva >= @initVal + @moduleVal -- if riserva exceed more than 1 module value the initial value
				--set Consegna equal to what is exceeeded
				set @Consegna = @riserva - @initVal
			else
				set @Consegna = 0 
		end
	end
	else
	begin
			set @Consegna = 0 --if no initvalue is defined keep everything in float
	end

	return @Consegna
END
GO
