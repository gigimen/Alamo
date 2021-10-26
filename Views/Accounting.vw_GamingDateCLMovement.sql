SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_GamingDateCLMovement]
WITH SCHEMABINDING
AS
SELECT     
SourceGamingDate AS GamingDate, 
CAST(SUM(Quantity * (Denomination * 100)) AS int) AS CLMovement
FROM   Accounting.vw_AllTransactionDenominations
WHERE     (OpTypeID = 6) AND (DenoID IN (66, 67))
GROUP BY SourceGamingDate









GO
