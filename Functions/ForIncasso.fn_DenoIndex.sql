SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE FUNCTION [ForIncasso].[fn_DenoIndex] (
@ValueTypeID INT,
@DenoID		INT
)  
RETURNS INT 
AS  
BEGIN 
	declare @i int
	SET @i = 
	CASE 
		WHEN @ValueTypeID = 1 THEN @DenoID
		WHEN @ValueTypeID = 36 THEN @DenoID - 127		
		WHEN @ValueTypeID = 42 THEN @DenoID - 194
		ELSE NULL
	END

	RETURN @i
END







GO
