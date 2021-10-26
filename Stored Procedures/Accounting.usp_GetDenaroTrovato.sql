SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetDenaroTrovato] 
@LifeCycleID		INT,
@currencyID			INT,
@totDenaroCents		INT OUTPUT,
@countDenaro		INT OUTPUT
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
	@totDenaroCents =
	ISNULL(
		SUM(
			(
			CASE 
			WHEN [RestGamingDate] = @GamingDate AND GamingDate = @GamingDate THEN 0
			WHEN [RestGamingDate] = @GamingDate THEN -1
			ELSE 1
			END) * [CHFCents]
			),
		0),
	@countDenaro =
	ISNULL(	
			COUNT(*)
			,0
		   )
	FROM [Accounting].[vw_AllDenaroTrovato]
	WHERE (GamingDate = @GamingDate OR [RestGamingDate] = @GamingDate)
	AND ([CHFCents] IS NOT NULL OR [CHFCents] > 0)
ELSE
	SELECT 
	@totDenaroCents =
	ISNULL(
		SUM(
			(
			CASE 
			WHEN [RestGamingDate] = @GamingDate AND GamingDate = @GamingDate THEN 0
			WHEN [RestGamingDate] = @GamingDate THEN -1
			ELSE 1
			END) * [EURCents]
			),
		0),
	@countDenaro =
	ISNULL(	
			COUNT(*)
			,0
		   )
	FROM [Accounting].[vw_AllDenaroTrovato]
	WHERE (GamingDate = @GamingDate OR [RestGamingDate] = @GamingDate)
	AND ([EURCents] IS NOT NULL OR [EURCents] > 0)




GO
