SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [GoldenClub].[usp_GetTotIngressi]
@NumEntrate	int output,
@NumUscite	int output
AS

-- get gaming date
declare @gaming datetime
set @gaming = getdate()
select @gaming = GeneralPurpose.fn_GetGamingLocalDate2 (@gaming,0,22)

/*
PRINT @gaming

DECLARE @NumEntrance int
		SELECT @NumEntrance = VisiteTotali FROM GoldenClub.vw_CKEntrancesByGamingDate
		WHERE GamingDate = @gaming
PRINT @NumEntrance
*/
		SELECT @NumEntrate = EntrateTotali FROM GoldenClub.vw_CKEntrancesByGamingDate
		WHERE GamingDate = @gaming

		SELECT @NumUscite = sum(Increment) FROM [Snoopy].[tbl_Uscite]
		WHERE GamingDate = @gaming
GO
