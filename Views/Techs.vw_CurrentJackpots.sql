SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Techs].[vw_CurrentJackpots]
AS
/*



SELECT JpId,jpName
FROM [DRGT].[drMenhelper].[Jackpots].[vw_CurrentJackpots]


*/

SELECT [JpId]
      ,[jpName]
  FROM [drFakMendrisio].[dbo].[vw_CurrentJackpots]

GO
