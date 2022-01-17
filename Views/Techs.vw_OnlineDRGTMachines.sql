SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Techs].[vw_OnlineDRGTMachines]
AS
/*


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
  FROM [drFakMendrisio].[dbo].[vw_OnlineDRGTMachines]

GO
GRANT SELECT ON  [Techs].[vw_OnlineDRGTMachines] TO [FloorUsage]
GO
