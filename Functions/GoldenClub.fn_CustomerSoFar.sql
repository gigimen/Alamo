SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  FUNCTION [GoldenClub].[fn_CustomerSoFar] 
(
	@gamingdate datetime
)  
RETURNS INT
AS  
BEGIN 
	DECLARE @cat INT
	SELECT @cat = COUNT(CustomerID)
	FROM Snoopy.tbl_Customers
	WHERE InsertDate <= @gamingdate
			 
	RETURN @cat
END





GO
