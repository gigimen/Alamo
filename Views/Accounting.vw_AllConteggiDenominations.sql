SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Accounting].[vw_AllConteggiDenominations]
with SCHEMABINDING
AS

SELECT  
	con.ConteggioID,
	con.SnapShotTypeID,
	st.FName as TipoConteggio,
	con.GamingDate,
	v.[StockID],
	s.Tag,
	s.StockTypeID,
	v.DenoID, 
	d.FDescription as DenoName,
	d.Denomination,
	d.ValueTypeID,
	vt.FName as ValueTypeName,
	cu.CurrencyID,
	cu.IsoName AS CurrencyAcronim,
	v.Quantity,
	v.ExchangeRate,
	v.Quantity * d.Denomination * v.ExchangeRate as ValueSfr,
	con.[ConteggioTimeUTC],
	GeneralPurpose.fn_UTCToLocal(1,con.[ConteggioTimeUTC]) 	as ConteggioTimeLoc
FROM    Accounting.tbl_Conteggi con
inner join CasinoLayout.SnapshotTypes st on st.SnapShotTypeID = con.SnapShotTypeID
INNER JOIN Accounting.tbl_ConteggiValues v on v.ConteggioID = con.ConteggioID
INNER JOIN CasinoLayout.tbl_Denominations d on d.DenoID = v.DenoID
INNER JOIN CasinoLayout.tbl_ValueTypes vt on vt.ValueTypeID = d.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID
INNER JOIN CasinoLayout.Stocks s on s.StockID = v.StockID
where con.CancelID is null
GO
