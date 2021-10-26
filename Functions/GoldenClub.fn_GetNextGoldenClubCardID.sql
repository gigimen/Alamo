SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  FUNCTION [GoldenClub].[fn_GetNextGoldenClubCardID] 
(
)  
RETURNS INT
AS  
BEGIN 
	declare @nextID INT
	select @nextID = max(GoldenClubCardID) 
		from GoldenClub.tbl_Cards
	where GoldenClubCardID < 500000
	RETURN @nextID + 1
END



GO
