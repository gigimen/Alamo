SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE   VIEW [Snoopy].[vw_AllFasceEtaRegistrations] 
AS
SELECT 
	[PK_VetoIngresso]
      ,r.[GamingDate]
      ,[entratatimestampUTC]
      ,[entratatimestampLoc]
      ,[FK_ControlID]
      ,f.FDescription AS [FasciaEta]
      ,CASE WHEN [Sesso] = 0 THEN 'Maschio' WHEN [Sesso] = 1 THEN 'Femmina' ELSE NULL END AS sesso
      ,p.Fdescription AS Provenienza
	  ,c.PK_ControllID
	  ,c.searchString
	  ,c.HitsNumber
	  ,c.TimeStampLoc AS controltime
	  ,s.FName AS SiteName
	  ,u.LongName
  FROM Reception.tbl_FasceEtaRegistrations r
  INNER JOIN Reception.tbl_VetoControls c ON c.PK_ControllID = r.FK_ControlID
  INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteId
  INNER JOIN CasinoLayout.Users u ON c.UserID = u.UserID
  LEFT OUTER JOIN [Snoopy].[tbl_FasceEta] f ON f.FasciaEtaID = r.FasciaEtaID
  LEFT OUTER JOIN [Snoopy].[tbl_Provenienza] p ON p.[ProvenienzaID] = r.[ProvenienzaID]
GO
