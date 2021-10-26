SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Snoopy].[vw_VetoEsclusioniMendrisio]
AS
SELECT     	
	FirstName, 
	LastName, 
    City, 
	Birthday, 
    BarrierStart,   
	[Dossier] AS [Description],
	Remarks,  
	CasinoName
FROM [Veto].[veto].[vw_VetoExclusions]
WHERE IsMendrisio = 1

GO
