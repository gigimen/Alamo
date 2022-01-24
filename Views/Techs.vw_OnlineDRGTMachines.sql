SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Techs].[vw_OnlineDRGTMachines]
AS
/*
SELECT 
CAST (FloorSfr AS BIT) AS FloorSfr,
CAST([LOCATION] AS INT) AS LOCATION
,CAST(REPLACE([Denomination],',','.') AS FLOAT) AS Denomination
--,cast(replace([DENOSFR],',','.') as float) as Denomination
,[MANUF]
,[Model]
,[SMDBID]
,CAST([DAT_DDEF] AS DATETIME) AS DAT_DDEF
,[MINBETSFR]
,[MAXBETSFR]
,[MAXWINSFR]
,[PCT_REDIST]
,[MECCCOUNTTYPE]
,[ELECOUNTTYPE]
 --FROM [Galaxis]..[MIS].[AD_ALL_SLOT_DEFINITIONS]
 ,NUM_SERIE
,CAST (1 AS BIT) AS IsActive
 FROM [Galaxis]..[MIS].[ONLINE_MACHINES]

*/


SELECT [SlotNr]
      ,[IpAddr]
      ,[Location]
      ,[Manufacturer]
      ,[Model]
      ,[InventoryNr]
      ,[SerialNumber]
      ,[ContatoriMeccanici]
      ,[ContatoriElettronici]
      ,[MinBet]
      ,[MaxBet]
      ,[DenoCents]
      ,[PCT_REDIST]
FROM [DRGT].[drMenhelper].[Slots].[vw_OnlineMachines]


GO
GRANT SELECT ON  [Techs].[vw_OnlineDRGTMachines] TO [FloorUsage]
GO
