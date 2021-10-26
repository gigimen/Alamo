SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_GetAllSoftCounts]
@GamingDate datetime
 AS
--Check life cycle parameter
if (@GamingDate is null) 
	begin
		raiserror('Must specify a valid gaming date',16,-1)
		return (1)
	end
DECLARE @result datetime

SELECT  Accounting.tbl_Progress.LifeCycleID , 
	StockID,
	DenoID, 
	Quantity, 
	StateTime
--	dbo.fn_GetTicHour(StateTime, @GamingDate, @hourdiff) AS TicHour
FROM    Accounting.tbl_Progress
INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Progress.LifeCycleID
WHERE Accounting.tbl_LifeCycles.GamingDate = @GamingDate
order by Accounting.tbl_Progress.LifeCycleID,StateTime
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllSoftCounts] TO [SolaLetturaNoDanni]
GO
