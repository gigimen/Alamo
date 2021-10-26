SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllMovimentiGettoniGiocoEuro]
WITH SCHEMABINDING
AS
SELECT  
	ex.transactionID,
	ex.LifeCycleID,
	lf.GamingDate, 
	lf.StockID, 
	st.Tag, 
	st.StockTypeID,
	ex.DenoID,
	d.FName AS DenoName,
	ex.CausaleID,
	ex.TotGettoni,
	ex.ExchangeRate,
	GeneralPurpose.fn_RoundToClosest(ex.TotGettoni /	ex.ExchangeRate,0.01) AS TotEuro,
	ex.[ExchangeTimeUTC],
	GeneralPurpose.fn_UTCToLocal (1,ex.[ExchangeTimeUTC]) AS ora
FROM Accounting.tbl_MovimentiGettoniGiocoEuro ex
INNER JOIN Accounting.tbl_LifeCycles lf	ON lf.LifeCycleID = ex.LifeCycleID
INNER JOIN CasinoLayout.Stocks st	ON lf.StockID = st.StockID
INNER JOIN CasinoLayout.tbl_Denominations d	ON d.DenoID = ex.DenoID






GO
