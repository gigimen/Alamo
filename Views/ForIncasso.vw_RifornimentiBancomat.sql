SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [ForIncasso].[vw_RifornimentiBancomat]
AS
SELECT GAMINGDATE,
	CASE
	WHEN DenoID = 20 THEN REPLACE(UPPER(Tag),' ','') + '_RIFORNIMENTO'
	WHEN DENOID = 27 THEN REPLACE(UPPER(Tag),' ','') + '_PRELEVAMENTO'
	ELSE
		'XXXXX??'
	END AS ForIncassoTag
	,(Quantity*Denomination) AS Amount
FROM [Accounting].[vw_AllConteggiDenominations] 
WHERE SnapshotTypeID = 11

GO
