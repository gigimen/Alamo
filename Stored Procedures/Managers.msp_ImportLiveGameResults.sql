SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Managers].[msp_ImportLiveGameResults]
@fromdate DATETIME,
@todate datetime
AS

/*


declare @fromdate datetime
declare @todate datetime
set @fromdate = '9.1.2019'
set @todate = '9.30.2019'


--execute [Managers].[msp_ImportLiveGameResults] @fromdate ,@todate


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




--*/
TRUNCATE TABLE [ForIncasso].[tbl_tmpBSELiveGame]

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
GO
