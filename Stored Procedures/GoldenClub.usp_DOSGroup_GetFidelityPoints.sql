SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [GoldenClub].[usp_DOSGroup_GetFidelityPoints] 
@cardid INT ,
@points INT OUTPUT
AS

/*
DECLARE @cardid int,@points int
SET @cardid = 200000
--*/
	SELECT @points =FidelityPoints
	FROM [DOSAPP].[icasino]..[vw_CurrentAvailablePoints]
	WHERE club_code = CAST(@cardid AS VARCHAR(32))

	--SELECT @points AS points
GO
