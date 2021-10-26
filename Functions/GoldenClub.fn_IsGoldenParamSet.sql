SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [GoldenClub].[fn_IsGoldenParamSet] (
@CustomerID INT,
@paramIndex INT
)
RETURNS BIT 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @ret BIT
	SET @ret = 0
	IF EXISTS (SELECT CustomerID FROM GoldenClub.tbl_Members WHERE customerID = @CustomerID AND GoldenParams & @paramIndex = @paramIndex)
		SET @ret = 1
	RETURN @ret
END

GO
