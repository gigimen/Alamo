SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetDotazioneGettoni]
@gamingDate DATETIME 
AS
	IF @gamingDate IS NULL

		SET @gamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
				GETUTCDATE(),
				DATEDIFF(hh,GETUTCDATE(),GETDATE()),
				1 --tables
				)
	SELECT * from [Accounting].[fn_GetDotazioneGettoni] (@gamingDate)
GO
