SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_RifornimentiBancomat]
AS
SELECT GAMINGDATE,
	CASE
	when DenoID = 20 then REPLACE(UPPER(Tag),' ','') + '_RIFORNIMENTO'
	when DENOID = 27 then REPLACE(UPPER(Tag),' ','') + '_PRELEVAMENTO'
	Else
		'XXXXX??'
	end As Nome
	,(Quantity*Denomination) as Amount
FROM [Accounting].[vw_AllConteggiDenominations] 
WHERE SnapshotTypeID = 11
GO
