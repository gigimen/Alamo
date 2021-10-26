SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE VIEW [ForIncasso].[vw_ConteggioGastro]
AS
	  SELECT 
			GamingDate,
			'GASTRO_COUNTED_' + CurrencyAcronim + '_'  + UPPER(Tag) AS 'ForIncassoTag',
			SUM(Quantity*Denomination) AS Amount
	FROM Accounting.vw_AllConteggiDenominations
	  WHERE SnapshotTypeID = 10
	  GROUP BY CurrencyAcronim,Tag,gamingdate
GO
