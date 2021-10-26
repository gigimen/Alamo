SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Managers].[msp_ShiftLifeCyleToToday]
AS

DECLARE @lastg DATETIME
DECLARE @currg DATETIME

SELECT @lastg = MAX(GamingDate) FROM Accounting.tbl_LifeCycles

SELECT @currg = GeneralPurpose.fn_GetGamingLocalDate2(GETUTCDATE(),1,7)

IF @currg > @lastg 
BEGIN
	PRINT 'Changing gamingdate'
	UPDATE Accounting.tbl_LifeCycles
	SET GamingDate = @currg
	WHERE GamingDate = @lastg

	UPDATE Accounting.tbl_CurrencyGamingdateRates
	SET GamingDate = @currg
	WHERE GamingDate = @lastg
END
ELSE
	PRINT 'last gamingdate is already current gamingdate'

GO
