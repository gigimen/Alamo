SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Managers].[msp_TestOutputParams]
@ssid INT OUTPUT,
@ora DATETIME output
AS
	--RAISERROR(50001,18,1,'diciannove')
	SET @ssid = 777
	SET @ora = GeneralPurpose.fn_GetGamingLocalDate2(GetUTCDate(),1,7) --CC GamingDate
GO
