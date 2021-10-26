SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_TicketsOldStuff]
--WITH SCHEMABINDING
AS
SELECT [TicketNumber]
	  ,[FloorSfr]
      ,[TicketType]
      ,[AmountCents]
		,CONVERT(FLOAT,ti.[AmountCents]) / 100.0 AS Importo
      ,[IssueTime]
      ,cast ([IssueLocation] AS INT) AS [IssueLocation]
      ,[IssueSMDBID]
      ,[RedeemTimestampLocal]
      ,[RedeemStockID]
	  ,st.Tag	AS RedeemTag
  FROM [OldStuff].[tickets].[tbl_LiableTickets] ti
LEFT OUTER JOIN CasinoLayout.Stocks st ON st.StockID = ti.RedeemStockID









GO
