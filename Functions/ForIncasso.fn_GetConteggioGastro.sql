SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE function [ForIncasso].[fn_GetConteggioGastro] (@gaming datetime)
RETURNS   @gastro TABLE(
	[ForIncassoTag] VARCHAR(64),
	[Amount]	FLOAT)
AS
BEGIN

INSERT INTO @gastro
(
	[ForIncassoTag],
	[Amount]
)

/*
declare @gaming datetime

set @gaming = '1.20.2022'
select * from [ForIncasso].[fn_GetConteggioGastro] (@gaming )

--*/
SELECT 
	'GASTRO_COUNTED_' + CurrencyAcronim + '_'  + UPPER(Tag) AS 'ForIncassoTag',
	SUM(Quantity*Denomination) AS Amount
FROM Accounting.vw_AllConteggiDenominations
WHERE SnapshotTypeID = 10 AND gamingdate = @gaming
GROUP BY CurrencyAcronim,Tag

INSERT INTO @gastro ([ForIncassoTag],[Amount]) SELECT 'GASTRO_FONDO_RISTO_CHF' AS 'ForIncassoTag',1800 AS Amount
INSERT INTO @gastro ([ForIncassoTag],[Amount]) SELECT 'GASTRO_FONDO_BAR_CHF' AS 'ForIncassoTag',1500 AS Amount
INSERT INTO @gastro ([ForIncassoTag],[Amount]) SELECT 'GASTRO_FONDO_RISTO_EUR' AS 'ForIncassoTag',0 AS Amount
INSERT INTO @gastro ([ForIncassoTag],[Amount]) SELECT 'GASTRO_FONDO_BAR_EUR' AS 'ForIncassoTag',0 AS Amount

RETURN 
END
GO
