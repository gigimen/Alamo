SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Accounting].[fn_TableApertura] (
@closegamingdate	datetime,
@chiusura			int,
@consegna			int,
@ripristino			int
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @outVal int

	if @closegamingdate <'3.23.2017'
		set @outVal = @chiusura - @consegna + @ripristino
	else
		set @outVal = @chiusura + @ripristino	
	return @outVal
END



GO
