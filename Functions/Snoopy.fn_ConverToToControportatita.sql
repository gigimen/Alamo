SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Snoopy].[fn_ConverToToControportatita] (
@CauseID	INT,
@DenoID		INT,
@PrelievoEuro bit
)  
RETURNS INT 
AS  
BEGIN 
	declare @i int
    SELECT @i = CASE 
	--CauseID		DenoID	PrelievoEuro					  then 
	when @CauseID  = 15	and @DenoID = 99	and @PrelievoEuro = 0  then 	3  --aduno prelievo franchi valuta
	when @CauseID  = 15	and @DenoID = 99	and @PrelievoEuro = 1  then 	1  --aduno prelieva euro valuta
	when @CauseID  = 16	and @DenoID = 99	and @PrelievoEuro = 0  then 	5  --aduno prelievo gettoni gioco chf
	when @CauseID  = 16	and @DenoID = 99	and @PrelievoEuro = 1  then 	4  --aduno prelievo gettoni gioco eur
	when @CauseID  = 15	and @DenoID = 90	and @PrelievoEuro = 0  then 	3  --globalcash franco valuta
	when @CauseID  = 16	and @DenoID = 90	and @PrelievoEuro = 0  then 	5 --globalcash

	END 
	RETURN @i
END
GO
