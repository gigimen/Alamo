SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [GoldenClub].[vw_CarteDaCreare]
WITH SCHEMABINDING
AS
SELECT  
	gc.GoldenClubCardID
FROM  GoldenClub.tbl_Cards gc
WHERE gc.GoldenClubCardID >= 107001 AND gc.GoldenClubCardID < 500000












GO
