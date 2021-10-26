SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Accounting].[fn_MonthlyJackpotPayments]
(
@fromdate DATETIME,
@todate		DATETIME
)
RETURNS @Return TABLE(
 JpID				VARCHAR(4),
 JpName				VARCHAR(50),
 StartTime			DATETIME,
 StartGamingDay		DATETIME,
 StartInstance		INT,
 EndTime			DATETIME,
 EndGamingDay		DATETIME,
 EndInstance		INT,
 TotalJPCents		INT
		)
AS
BEGIN

/*
select * from [Accounting].[fn_MonthlyJackpotPayments] ('11.1.2020','11.30.2020')

*/
INSERT INTO @Return
(
	JpID,
    JpName,
    StartTime,
    StartGamingDay,
    StartInstance,
    EndTime,
    EndGamingDay,
    EndInstance,
    TotalJPCents
)
/*
DECLARE @fromdate DATETIME,@todate datetime

SET @fromdate = '11.1.2020'
SET @todate = '11.30.2020'
--*/

SELECT j.[JpID],
	[JackpotName],  
	h.minTime,
	h.minGamingDate,
	h.minInstance,
	h.maxTime,
	h.maxGamingDate,
	h.maxInstance,
	ISNULL(h.TotalJP, 0 ) AS TotalJPCents

FROM [CasinoLayout].[Jackpots] j
LEFT OUTER JOIN
(
SELECT 
jpID,
MIN(IssueTimeLoc) AS minTime,
MAX(IssueTimeLoc) AS maxTime,
MIN(GamingDate) AS minGamingDate,
MAX(GamingDate) AS maxGamingDate,
MIN(JpInstance) AS minInstance,
MAX(JpInstance) AS maxInstance,
SUM(AmountCents) AS TotalJP
FROM [Accounting].[vw_AllSlotTransactions]
WHERE gamingdate BETWEEN @fromdate AND @todate AND OpTypeID = 15
GROUP BY jpID
) h ON h.JpID = j.JpID
WHERE j.jpid IN('MJP1','MJP2','MJP3')
ORDER BY j.JpID 

RETURN 
END


GO
