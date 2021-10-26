SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[vw_Reg100000in365]
AS
SELECT COUNT(*) [NumRegistrazioni]
	  ,SUM([Importo]) AS [TotaleImporto]
	  ,MIN(TimeStampUTC) AS Dal
	  ,MAX(TimeStampUTC) AS Al
	  ,[CustomerID]
      ,[FirstName]
      ,[LastName]
      ,[BirthDate]
      ,[transazione]
      
  FROM [Snoopy].[vw_AllRegistrations]
  WHERE [GamingDate] >= DATEADD(YEAR,-1,GETUTCDATE())
  GROUP BY [CustomerID]
      ,[FirstName]
      ,[LastName]
      ,[BirthDate]
      ,[transazione]
	  HAVING SUM([Importo]) > 100000
GO
