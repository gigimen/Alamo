SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [CasinoLayout].[Denominations]
AS
SELECT [DenoID]
      ,[ValueTypeID]
      ,[Denomination]
      --,[IsFisical]
      ,[FName]
      ,[FDescription]
      ,[DoNotDisplayQuantity]
  FROM [CasinoLayout].[tbl_Denominations]
GO
