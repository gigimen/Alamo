SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE FUNCTION [GoldenClub].[fn_QuantiInvitiCena] (
@gamingdate datetime
)
RETURNS INT
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @r INT

	--se quel gionr c'è un evento ritorna 0
	if exists( select eventoId from  [Marketing].[tbl_Eventi] where GamingDate = @gamingdate)
		set @r = 0
	else
		set @r = case	
			--sabato e domenica 5
			when DATEPART(weekday,@gamingdate) = 1 then 5 
			when DATEPART(weekday,@gamingdate) = 7 then 5 
			--venerdi 5
			when DATEPART(weekday,@gamingdate) = 6 then 5 
			else
			--tutti gli altri giorni 10
				10
			end
	RETURN @r
END


GO
