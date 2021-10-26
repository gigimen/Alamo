SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [GoldenClub].[usp_DOSGroup_IsClubVerified] 
@cardid INT ,
@verified BIT OUTPUT
AS

	DECLARE @email VARCHAR(200)
	--SET @cardid = 200001

	SELECT 
			@verified = club_verified, 
			@email = email
	FROM [DOSAPP].[icasino]..[user] 
	WHERE club_code = CAST(@cardid AS VARCHAR(32))

	SELECT @verified AS verified,@email AS email

GO
