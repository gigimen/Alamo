SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Snoopy].[vw_VetoChangesByGamingDate]
AS

SELECT [BarrierID]
      ,[FirstName]
      ,[LastName]
      ,[Birthday]
      ,[Address]
      ,[CountryISOCode]
      ,[Country]
      ,[NationalityISOCode]
      ,[Nationality]
      ,[Zip]
      ,[City]
      ,[CreateDate]
 	  ,[GeneralPurpose].[fn_GetGamingDate]([CreateDate],0,DEFAULT) AS GamingDate--change at 9 am by default 
     ,[Editor]
      ,[Dossier]
      ,[Remarks]
      ,[BarrierStart]
      ,[BarrierEnd]
      ,[IsMendrisio]
      ,[CasinoName]
      ,[Barrier]
      ,[BarrierLevel]
      ,[BarrierReasonNumber]
      ,[BarriedBy]
      ,[MaxEntries]
      ,[Deleted]
      ,[Timestamp]
  FROM [Veto].[veto].[vw_VetoExclusions]
GO
