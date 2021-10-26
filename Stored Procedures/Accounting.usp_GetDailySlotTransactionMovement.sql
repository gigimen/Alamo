SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [Accounting].[usp_GetDailySlotTransactionMovement]
@lfid INT
AS
/*


declare @lfid int

set @lfid=177544
	SELECT * FROM [Accounting].[vw_AllSlotTransactions]	WHERE [LifeCycleID] = @lfid

--*/


	SELECT 
		ISNULL(COUNT(CASE WHEN OpTypeID = 15 THEN 1				ELSE NULL end),0)					AS cntJP, 
		ISNULL(SUM	(CASE WHEN OpTypeID = 15 THEN [AmountCents] ELSE NULL end),0)					AS totJP,
		ISNULL(COUNT(CASE WHEN OpTypeID = 16 AND Currency= 4 THEN 1				ELSE NULL end),0)	AS cntHPCHF, 
		ISNULL(SUM	(CASE WHEN OpTypeID = 16 AND Currency= 4 THEN [AmountCents] ELSE NULL end),0)	AS totHPCHF,
		ISNULL(COUNT(CASE WHEN OpTypeID = 16 AND Currency= 0 THEN 1				ELSE NULL end),0)	AS cntHPEUR, 
		ISNULL(SUM	(CASE WHEN OpTypeID = 16 AND Currency= 0 THEN [AmountCents] ELSE NULL end),0)	AS totHPEUR,
		ISNULL(COUNT(CASE WHEN OpTypeID = 17 AND Currency= 4 THEN 1				ELSE NULL end),0)	AS cntSPCHF, 
		ISNULL(SUM	(CASE WHEN OpTypeID = 17 AND Currency= 4 THEN [AmountCents] ELSE NULL end),0)	AS totSPCHF,
		ISNULL(COUNT(CASE WHEN OpTypeID = 17 AND Currency= 0 THEN 1				ELSE NULL end),0)	AS cntSPEUR, 
		ISNULL(SUM	(CASE WHEN OpTypeID = 17 AND Currency= 0 THEN [AmountCents] ELSE NULL end),0)	AS totSPEUR
	FROM [Accounting].[vw_AllSlotTransactions]
	WHERE [LifeCycleID] = @lfid





GO
