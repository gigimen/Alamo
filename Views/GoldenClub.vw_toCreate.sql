SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [GoldenClub].[vw_toCreate]
AS
SELECT [GoldenClubCardID]
 
  FROM [Alamo].[GoldenClub].[vw_AllGoldenCards]
  WHERE GoldenClubCardID > 106000 AND  GoldenClubCardID <= 106500
GO
