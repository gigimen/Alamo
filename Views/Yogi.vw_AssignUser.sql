SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Yogi].[vw_AssignUser] AS

SELECT 
	   tbAC.Id
	  ,[IdBadgeNumber]
	  ,[Description]
	  ,tbUser.LastName + ' ' + tbUser.FirstName AS UserName	
      ,[DataStart]
      ,[DataEnd]
      ,tbAC.Note
	  ,tbSecUserStart.LastName + ' ' + tbSecUserStart.FirstName AS UserStart
	  ,tbSecUserEnd.LastName + ' ' + tbSecUserEnd.FirstName AS UserEnd
	  
FROM [Yogi].[AssignUser] AS tbAC

INNER JOIN [Yogi].[Badge] AS tbB
ON tbAC.IdBadgeNumber = tbB.Number

INNER JOIN [CasinoLayout].[Users] AS tbUser
ON tbAC.UserID = tbUser.UserID

INNER JOIN [CasinoLayout].[Users] AS tbSecUserStart
ON tbAC.IdUserStart = tbSecUserStart.UserID

LEFT OUTER JOIN [CasinoLayout].[Users] AS tbSecUserEnd
ON tbAC.IdUserEnd = tbSecUserEnd.UserID

--ORDER BY DataEnd Desc
GO
