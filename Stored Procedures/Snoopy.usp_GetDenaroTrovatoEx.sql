SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Snoopy].[usp_GetDenaroTrovatoEx] 
@LifeCycleID INT,
@currencyID	INT,
@totDenaro FLOAT OUTPUT,
@countDenaro INT OUTPUT
AS

IF @LifeCycleID IS NULL AND NOT EXISTS (SELECT LifeCycleID FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @LifeCycleID)
BEGIN
	RAISERROR('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	RETURN 1
END

IF @currencyID IS NULL AND NOT @currencyID IN(0,4)
BEGIN
	RAISERROR('Invalid @currencyID (%d) specified ',16,1,@currencyID)
	RETURN 1
END

DECLARE @GamingDate DATETIME
SELECT @GamingDate = GamingDate FROM Accounting.tbl_LifeCycles
WHERE LifeCycleID = @LifeCycleID

IF @currencyID = 4 --CHF
	SELECT 
	@totDenaro =
	ISNULL(
		SUM(
			(
			CASE 
			WHEN Rap_Datarestituzione = @GamingDate AND Rap_GamingDate = @GamingDate THEN 0
			WHEN Rap_Datarestituzione = @GamingDate THEN -1
			ELSE 1
			END) * Rap_ImportoCHF
			),
		0),
	@countDenaro =
	ISNULL(	
			COUNT(*)
			,0
		   )
	FROM Snoopy.tbl_DenaroTrovato
	WHERE (Rap_GamingDate = @GamingDate OR Rap_Datarestituzione = @GamingDate)
	AND Rap_ImportoCHF IS NOT null
ELSE
	SELECT 
	@totDenaro =
	ISNULL(
		SUM(
			(
			CASE 
			WHEN Rap_Datarestituzione = @GamingDate AND Rap_GamingDate = @GamingDate THEN 0
			WHEN Rap_Datarestituzione = @GamingDate THEN -1
			ELSE 1
			END) * Rap_ImportoEuro
			),
		0),
	@countDenaro =
	ISNULL(	
			COUNT(*)
			,0
		   )
	FROM Snoopy.tbl_DenaroTrovato
	WHERE (Rap_GamingDate = @GamingDate OR Rap_Datarestituzione = @GamingDate)
	AND Rap_ImportoEuro IS NOT null




GO
