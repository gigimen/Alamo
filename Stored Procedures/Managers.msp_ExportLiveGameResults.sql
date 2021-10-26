SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Managers].[msp_ExportLiveGameResults]
@rows INT OUTPUT,
@todate DATETIME output
AS
DECLARE @mindate datetime
declare @fromdate datetime

SELECT @mindate = MIN(gamingDate) FROM [ForIncasso].[tbl_tmpBSELiveGame]
PRINT @mindate
SELECT @fromdate = DATEADD(DAY,1,MAX(gamingDate)) FROM [ForIncasso].[tbl_tmpBSELiveGame]
PRINT @fromdate

--yeasterday results are availabel only at 15:00!! go back one day
SELECT @todate =  DATEADD(DAY,-1,GeneralPurpose.fn_GetGamingDate(GETDATE(),0,11))

PRINT @todate


IF(DATEDIFF(DAY,@mindate,@todate) > 365 )
BEGIN
	PRINT 'truncate table because it too big'
	TRUNCATE TABLE [ForIncasso].[tbl_tmpBSELiveGame]
END


INSERT INTO [ForIncasso].[tbl_tmpBSELiveGame]
           ([Tag]
           ,[CurrencyID]
           ,[GamingDate]
           ,[Fills]
           ,[Credits]
           ,[EstimatedDrop]
           ,[CashBox]
           ,[Apertura]
           ,[Chiusura]
           ,[Tronc]
           ,[CurrencyRate]
           ,[LucyChipsPezzi])





select		[Tag]
           ,[CurrencyID]
           ,[GamingDate]
           ,[Fills]
           ,[Credits]
           ,[EstimatedDrop]
           ,[totConteggio]
           ,[Apertura]
           ,[Chiusura]
           ,[Tronc]
           ,CASE WHEN CurrencyID = 4 THEN 1.0 ELSE [EuroRate] END AS [CurrencyRate]
           ,[LuckyChipsPezzi] 
FROM [ForIncasso].[fn_GetBSELiveGame] (@fromdate,@todate)


SET @rows = @@ROWCOUNT
SELECT @todate = MAX(GamingDate) FROM [ForIncasso].[tbl_tmpBSELiveGame]

GO
