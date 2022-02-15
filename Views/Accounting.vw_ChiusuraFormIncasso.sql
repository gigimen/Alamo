SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_ChiusuraFormIncasso]
AS
SELECT 
	GamingDate,
	StockID,
	FName AS Stock,
	CurrencyID,
	CurrencyAcronim,
	Quantity,
	Denomination,
	Quantity*Denomination AS Totale,
	DenoID,
	CASE
	WHEN DenoID IN(103,163) THEN 'Cash ' + CurrencyAcronim
	WHEN DenoID IN(110,167) THEN 'Prelievo Banca ' + CurrencyAcronim
	WHEN DenoID IN(109,166) THEN 'Versamento Banca ' + CurrencyAcronim
	ELSE 'Vendita Tichange ' + CurrencyAcronim
	END AS Tipo
FROM [Alamo].[Accounting].[vw_AllConteggiDenominations]
WHERE SnapShotTypeID  = 6 
GO
