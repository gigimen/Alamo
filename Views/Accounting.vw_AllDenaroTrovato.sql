SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Accounting].[vw_AllDenaroTrovato]
AS
SELECT [PK_DenaroTrovatoID]
      ,[FK_UserAccessID]
      ,dt.[GamingDate]
      ,[PK_DenaroTrovatoID] AS [NumeroRapporto]
      ,GeneralPurpose.fn_UTCToLocal(1,[TimeStampUTC]) AS OraLoc
      ,[CHFCents]
      ,[EURCents]
	  ,CASE WHEN [EURCents] IS NOT NULL then
		CAST(ISNULL(CHFCents,0) AS FLOAT ) /100.0 + CAST(ISNULL(EURCents,0) AS FLOAT ) /100.0 * e.IntRate 
		else
		CAST(ISNULL(CHFCents,0) AS FLOAT ) /100.0 
		END	AS TotalCHF
      ,[LuogoRitrovo]
      ,[Osservazioni]
      ,[Trovatore]
      ,[DataControllo]
      ,[ImportiInf10]
	  ,c.LastName
	  ,c.FirstName
	  ,c.CustomerID
	  ,c.BirthDate
	  ,r.PK_RestituzioneID
	  ,r.RestGamingDate
	  ,r.[RappSorv]
	  ,GeneralPurpose.fn_UTCToLocal(1,r.RestTimeStampUTC) AS OraRestituzioneLoc
FROM [Accounting].[tbl_DenaroTrovato] dt
  INNER JOIN FloorActivity.tbl_UserAccesses ua ON ua.UserAccessID = dt.FK_UserAccessID
  LEFT OUTER JOIN Snoopy.tbl_CustomerRestituzioni r ON r.FK_DenaroTrovatoID = dt.PK_DenaroTrovatoID
  LEFT OUTER JOIN Snoopy.tbl_Customers c ON c.CustomerID = r.CustomerID
  LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates e ON e.GamingDate = dt.GamingDate AND e.CurrencyID = 0
  


GO
