SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Snoopy].[vw_YearlyBonifici]
AS
SELECT TOP 100 percent
      [LastName]
      ,[FirstName]
      ,Convert(VARCHAR(32),[BirthDate],105) AS DataDinascita
      ,[Address]
      ,[DocType]
      ,[DocNumber]
      ,[Euros]
	  ,'CA ' + CAST(BonificoID AS VARCHAR(16)) AS [N Assegno]
      ,[IBAN]
      ,[BankName] + ' ' + [BankAddress] AS IndirizzoBanca
      ,[ORDERTime]
	  ,'' AS Firma
  FROM [Snoopy].[vw_AllBonifici]
  WHERE DATEPART(YEAR,ORDERTime)  = 2016
  ORDER BY ORDERTime
GO
