SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  VIEW [Accounting].[vw_PendingSlotTransactions]
AS

SELECT [OutIpAddrDesc]
      ,[OutIpAddr]
      ,[ValidationNumber]
      ,[Amount]				AS AmountCents
      ,[Currency]
      ,[IssueTimeUTC]
      ,[IssueTimeLoc]
      ,CAST([GamingDate] AS DATETIME) AS GamingDate
      ,CASE WHEN [JpLevel] = 128 THEN 16 --handpay
		ELSE	15	--jackpot
		END AS OptypeId
      ,CASE WHEN [JpLevel] = 128 THEN 'Handpay'
		ELSE	'Jackpot'
		END AS OptypeName
		,JpID
      ,[JpName]	
      ,[JpInstance]	
  FROM [DRGT].drMenHelper.[Slots].[vw_PendingTransactions]

GO
