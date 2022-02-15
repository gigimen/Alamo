SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllConteggiDenominations]
WITH SCHEMABINDING
AS

SELECT  
	con.ConteggioID,
	con.SnapShotTypeID,
	st.FName AS TipoConteggio,
	st.SorvDoubleCheck,
	con.GamingDate,
	v.[StockID],
	s.Tag,
	s.FName,
	s.StockTypeID,
	v.DenoID, 
	d.FDescription AS DenoName,
	d.Denomination,
	d.ValueTypeID,
	vt.FName AS ValueTypeName,
	cu.CurrencyID,
	cu.IsoName AS CurrencyAcronim,
	v.Quantity,
	v.ExchangeRate,
	v.Quantity * d.Denomination * v.ExchangeRate AS ValueSfr,
	con.[ConteggioTimeUTC],
	GeneralPurpose.fn_UTCToLocal(1,con.[ConteggioTimeUTC]) 	AS ConteggioTimeLoc
FROM    Accounting.tbl_Conteggi con
INNER JOIN CasinoLayout.SnapshotTypes st ON st.SnapShotTypeID = con.SnapShotTypeID
INNER JOIN Accounting.tbl_ConteggiValues v ON v.ConteggioID = con.ConteggioID
INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = v.DenoID
INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = d.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID
INNER JOIN CasinoLayout.Stocks s ON s.StockID = v.StockID
WHERE con.CancelID IS NULL
GO
