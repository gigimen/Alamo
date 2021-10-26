SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Accounting].[fn_TableChiusura] (
@closegamingdate	datetime,
@chiusura			int,
@consegna			int
)  
RETURNS int 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @outVal int

	if @closegamingdate <'3.23.2017'
		set @outVal = @chiusura
	else
		set @outVal = @chiusura + @consegna
	
	return @outVal
END



GO
