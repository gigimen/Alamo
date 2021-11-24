SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE FUNCTION [ForIncasso].[fn_AcronimEx] (
@ValueTypeID	INT
)  
RETURNS VARCHAR(64) 
AS  
BEGIN 
	declare @i varchar(4)


	SELECT @i =
	CASE 

	WHEN @ValueTypeID = 1		THEN 'CHF'
	WHEN @ValueTypeID = 36		THEN 'CHFE'
	WHEN @ValueTypeID = 42		THEN 'EUR'
	WHEN @ValueTypeID = 59		THEN 'POK'
	ELSE NULL
	END

	RETURN @i
END







GO
