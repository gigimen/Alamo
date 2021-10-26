SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Techs].[vw_AllSlotDefinitions]
AS
/*
SELECT 
0 AS FloorSfr,
0 AS LOCATION,
0.0 AS Denomination
,'' as [MANUF]
,'' as [Model]
,'' as [SMDBID]
,CAST(0 AS DATETIME) AS DAT_DDEF
,0.0 AS [MINBETSFR]
,0.0 AS [MAXBETSFR]
,0.0 AS [MAXWINSFR]
,0.0 AS [PCT_REDIST]
,'' as [MECCCOUNTTYPE]
,'' as [ELECOUNTTYPE]
,'' as [NUM_SERIE]
,CAST(0  AS BIT) AS IsActive
*/

/*
SELECT ISNULL(g.[LOCATION]			   , d.SlotNr)			AS  [SlotNr]			   
      ,ISNULL(g.[Denomination]		   , CAST(d.[DenoCents] AS FLOAT) / 100.0 ) AS  [Denomination]		   
      ,ISNULL(g.[MANUF]				   , d.[Manufacturer])	AS  [MANUF]				   
      ,ISNULL(g.[Model]				   , d.[Model])			AS  [Model]				   
      ,ISNULL(g.[SMDBID]			   , d.InventoryNr)		AS  [SMDBID]			   
      ,g.[DAT_DDEF]							   
      ,ISNULL(g.[MINBETSFR]			   , CAST(d.[MinBet] AS FLOAT) / 100.0 ) AS  [MINBETSFR]			   
      ,ISNULL(g.[MAXBETSFR]			   , CAST(d.[MaxBet] AS FLOAT) / 100.0 ) AS  [MAXBETSFR]			   
      --,ISNULL(g.[MAXWINSFR]			   , d.) AS  [MAXWINSFR]			   
      ,ISNULL(g.[PCT_REDIST]		   , d.[PCT_REDIST]) AS  [PCT_REDIST]		   
      --,ISNULL(g.[MECCCOUNTTYPE]		   , d.) AS  [MECCCOUNTTYPE]		   
      ,ISNULL(g.[ELECOUNTTYPE]		   , d.[ContatoriElettronici]) AS  [ELECOUNTTYPE]		   
      ,ISNULL(g.[NUM_SERIE]			   , d.[SerialNumber]) AS  [NUM_SERIE]			   	   
  FROM [Techs].[tbl_GalaxisSlotDefinitions] g
FULL OUTER JOIN [Techs].[vw_OnlineDRGTMachines] d ON g.[SMDBID] = d.[SlotNr]
*/

SELECT d.SlotNr										AS  [SlotNr]	
		,IpAddr --CAST([IpAddr] AS INT)						AS  IpAddr		   
      ,CAST(d.[DenoCents] AS FLOAT) / 100.0			AS  [Denomination]		   
      ,d.[Manufacturer]								AS  [MANUF]				   
      ,d.[Model]											   
      ,d.InventoryNr										   
      ,	NULL										AS [DAT_DDEF]   
      ,CAST(d.[MinBet] AS FLOAT) / 100.0			AS  [MINBETSFR]			   
      ,CAST(d.[MaxBet] AS FLOAT) / 100.0			AS  [MAXBETSFR]			   
		   
      ,d.[PCT_REDIST]								AS  [PCT_REDIST]		   	   
      ,d.[ContatoriElettronici]						AS  [ELECOUNTTYPE]		   
      ,d.[SerialNumber]								AS  [NUM_SERIE]			   	   
  FROM [Techs].[vw_OnlineDRGTMachines] d
GO
