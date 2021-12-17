SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllDRGTShortpays]
AS

---
SELECT 
GamingDate,
Tag,
IsSfr,
Importo,
CHF,
IssueTimeLoc,
PaymentTimeLoc,
[GeneralPurpose].[IPAddrToPosition](SlotNr) AS SlotNr,
[Nota]
FROM [Accounting].[vw_AllSlotTransactions]
WHERE OpTypeID = 17
GO
