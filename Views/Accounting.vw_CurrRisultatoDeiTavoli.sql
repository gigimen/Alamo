SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  VIEW [Accounting].[vw_CurrRisultatoDeiTavoli]
WITH SCHEMABINDING
AS
SELECT --a.*
a.Tag,a.DenoID,a.StateTimeLoc,a.Value

FROM 
(
SELECT 
	lf.LifeCycleID,
	p.DenoID,
	MAX(p.StateTime) AS MRTime
FROM Accounting.tbl_Progress p
	INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = p.LifeCycleID
	INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID
WHERE lf.GamingDate = --'8.28.2020'
		GeneralPurpose.fn_GetGamingLocalDate2(
		GETUTCDATE(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GETUTCDATE(),GETDATE()),
		1 --Tavoli StockTypeID 
		) 
		AND st.StockTypeID = 1
		AND p.DenoID IN(23,11)
GROUP BY lf.LifeCycleID,
	p.DenoID
) p
INNER JOIN Accounting.vw_AllProgress a ON a.LifeCycleID = p.LifeCycleID AND a.StateTimeUTC = p.MRTime AND a.DenoID = p.DenoID
GO
