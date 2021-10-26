SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Yogi].[vw_AssignCompany] AS

SELECT 
	   tbAC.Id
	  ,[IdBadgeNumber]
	  ,[Description]
     -- ,[IdCompanyContact]
	  ,tbContact.LastName + ' ' +  tbContact.FirstName AS ContactName
	  ,tbCompany.Name AS CompanyName
      ,[DataStart]
      ,[DataEnd]
      ,tbAC.Note
    --  ,[IdUserStart]
	  ,tbSecUserStart.LastName + ' ' + tbSecUserStart.FirstName AS UserStart
    --  ,[IdUserEnd]
	  ,tbSecUserEnd.LastName + ' ' + tbSecUserEnd.FirstName AS UserEnd
	  
FROM [Yogi].[AssignCompany] AS tbAC

INNER JOIN [Yogi].[Badge] AS tbB
ON tbAC.IdBadgeNumber = tbB.Number

INNER JOIN [Yogi].[CompanyContact] AS tbContact
ON tbAC.IdCompanyContact = tbContact.Id

INNER JOIN [Yogi].[Company] AS tbCompany
ON tbContact.FK_IdCompany = tbCompany.Id

INNER JOIN [CasinoLayout].[Users] AS tbSecUserStart
ON tbAC.IdUserStart = tbSecUserStart.UserID

LEFT OUTER JOIN [CasinoLayout].[Users] AS tbSecUserEnd
ON tbAC.IdUserEnd = tbSecUserEnd.UserID

--ORDER BY DataEnd Desc
GO
