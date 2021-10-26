SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Techs].[vw_CurrentJackpots]
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


SELECT JpId,jpName
FROM [DRGT].[drMenhelper].[Jackpots].[vw_CurrentJackpots]
GO
