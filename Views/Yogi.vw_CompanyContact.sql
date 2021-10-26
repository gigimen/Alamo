SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Yogi].[vw_CompanyContact] AS

SELECT tbCC.[Id] 
      ,tbCC.[LastName]
      ,tbCC.[FirstName]
      ,[Phone]
	  ,tbDoc.Name AS DocName
      ,[DocNumber]
      ,tbCompany.Name AS CompanyName
	  ,[FK_IdCompany]
	  ,[FK_IdDocType]
      ,[CheckVeto]
	  ,tbUser.LastName + ' ' + tbUser.FirstName AS CheckVetoUser
      ,[DataCheckVeto] AS CheckVetoData
      ,tbcc.[Note]

FROM [Yogi].[CompanyContact] tbCC
  
INNER JOIN [CasinoLayout].[Users] AS tbUser
ON tbCC.IdUserCheckVeto = tbUser.UserID

INNER JOIN [Yogi].[Company] AS tbCompany
ON tbCC.FK_IdCompany = tbCompany.Id

INNER JOIN [Yogi].[DocType] AS tbDoc
ON tbCC.FK_IdDocType = tbDoc.Id

GO
