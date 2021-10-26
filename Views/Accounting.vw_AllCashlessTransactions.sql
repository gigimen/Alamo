SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Accounting].[vw_AllCashlessTransactions]
WITH SCHEMABINDING
AS
--corretto il case
SELECT  
	cls.CashlessTransID,
	cls.CardNumber, 
	lf.LifeCycleID, 
	lf.GamingDate, 
	st.Tag, 
	lf.StockID,
	case 
	when cls.ImportoCents > 0 then 'Scaricati'
	else 'Caricati'	end as DenoName,
	case 
	when cls.ImportoCents > 0 then 67
	else 66
	end as DenoID,
	GeneralPurpose.fn_UTCToLocal(1,cls.TransTime) AS TransTime, 
	cls.TransTime as TransTimeUTC,
	cls.ImportoCents,
	convert(float,cls.ImportoCents) / 100.0 as Importo
FROM    Accounting.tbl_CashlessTransactions cls 
INNER JOIN Accounting.tbl_LifeCycles lf ON cls.LifeCycleID = lf.LifeCycleID
inner join CasinoLayout.Stocks st on st.StockID = lf.StockID
GO
