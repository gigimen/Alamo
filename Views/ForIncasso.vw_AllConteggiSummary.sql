SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [ForIncasso].[vw_AllConteggiSummary]
WITH SCHEMABINDING
AS

SELECT  
	con.ConteggioID,
	con.SnapshotTypeID,
	st.FName AS TipoConteggio,
	con.GamingDate,
	con.[ConteggioTimeUTC],
	GeneralPurpose.fn_UTCToLocal(1,con.[ConteggioTimeUTC]) 	AS ConteggioTimeLoc,
	v.[StockID],
	s.StockTypeID,
	s.Tag,
	v.DenoID, 
	d.IsFisical,
	vt.FName AS ValueTypeName,
	vt.ValueTypeID,
	cu.CurrencyID,
	cu.IsoName AS Acronim,
	SUM(v.Quantity									)	AS Quantity,
	SUM(v.Quantity * d.Denomination					)	AS Value,
	SUM(v.Quantity * d.Denomination * v.ExchangeRate)	AS CHF
FROM    Accounting.tbl_Conteggi con
INNER JOIN CasinoLayout.SnapshotTypes st ON st.SnapshotTypeID = con.SnapshotTypeID
INNER JOIN Accounting.tbl_ConteggiValues v ON v.ConteggioID = con.ConteggioID
INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = v.Denoid
INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = d.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID
INNER JOIN CasinoLayout.Stocks s ON s.StockID = v.StockID
WHERE con.CancelID IS NULL
GROUP BY
con.ConteggioID,
	con.SnapshotTypeID,
	st.FName,
	con.GamingDate,
	con.[ConteggioTimeUTC],
	v.[StockID],
	s.StockTypeID,
	s.Tag,
	v.DenoID, 
	d.IsFisical,
	vt.FName,
	vt.ValueTypeID,
	cu.CurrencyID,
	cu.IsoName 
GO
