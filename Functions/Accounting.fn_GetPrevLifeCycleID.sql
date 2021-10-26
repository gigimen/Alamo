SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Accounting].[fn_GetPrevLifeCycleID] (
@gamingdate	DATETIME,
@stockid			INT
)  
RETURNS INT 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @outVal INT

	SELECT @outVal = LifeCycleID
	FROM Accounting.tbl_LifeCycles lf
	WHERE lf.StockID = @stockid AND gamingdate = 
	(
		SELECT MAX(lf.GamingDate) 
		FROM    Accounting.tbl_LifeCycles lf
		INNER JOIN Accounting.tbl_Snapshots Apertura ON Apertura.LifeCycleID = lf.LifeCycleID 
		AND Apertura.SnapshotTypeID = 1 --'Apertura'
		--apertura has not been cancelled
		AND Apertura.LCSnapShotCancelID IS NULL
		WHERE lf.StockID = @stockid AND Gamingdate < @gamingdate
	)
	RETURN @outVal
END





GO
