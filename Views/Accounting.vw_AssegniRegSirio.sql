SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_AssegniRegSirio]
AS
SELECT
	[AssegnoID]
      ,[NrAssegno]
	  ,[GamingDate]
	  ,[ControlDate]
	  ,EuroCents
      ,[Importo]
      ,Incassato
	  ,CommissioneBanca
	  ,RegistrazioneSirio
FROM
(
SELECT[AssegnoID]
      ,[NrAssegno] 
	  ,[GamingDate]
	  ,ControlDate
	  ,EuroCents
      ,[Importo]
      ,CAST([NettoIncassatoCents] AS FLOAT) /100.00 AS Incassato
	  ,CAST((EuroCents - [NettoIncassatoCents]) AS FLOAT) / 100.0 AS CommissioneBanca
	  ,[Accounting].[fn_Format_for_Sirio] ('10254','11006',CAST([NettoIncassatoCents] AS FLOAT) /100.00,[GamingDate],ControlDate,'Incasso Assegno ' + [NrAssegno]+ ' del ' + CONVERT(VARCHAR(16),[GamingDate],104),DEFAULT) AS RegistrazioneSirio

  FROM [Snoopy].[vw_AllAssegniEx]
  WHERE NettoIncassatoCents > 0
UNION ALL
SELECT[AssegnoID]
      ,[NrAssegno]
	  ,[GamingDate]
	  ,ControlDate  
	  ,EuroCents
      ,[Importo]
      ,CAST([NettoIncassatoCents] AS FLOAT) /100.00 AS Incassato
	  ,CAST((EuroCents - [NettoIncassatoCents]) AS FLOAT) / 100.0 AS CommissioneBanca
	  ,[Accounting].[fn_Format_for_Sirio] ('68406','11006',CAST((EuroCents - [NettoIncassatoCents]) AS FLOAT) / 100.0,[GamingDate],ControlDate,'Commissione Assegno ' + [NrAssegno]+ ' del ' + CONVERT(VARCHAR(16),[GamingDate],104),'INCASSO') AS Conto68406

  FROM [Snoopy].[vw_AllAssegniEx]
  WHERE NettoIncassatoCents > 0 AND ABS(EuroCents - [NettoIncassatoCents]) > 0

  )a
GO
