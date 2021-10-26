SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [GoldenClub].[vw_AllPartecipazioneEventi]
--WITH SCHEMABINDING
AS
SELECT  
/*
count(distinct EventoID)-- as NumeroEventi,
count(*) as TotPartecipazioni,
sum(gm.Accompagnati) as TotAccompagnati,
count(case when regIn.RegCountIn is null and regOut.RegCountOut is null and LRDregOut.RegCountOut is null and LRDRegIn.RegCountIn is null then null else 1 end) as TotConCambiEuro,
count(case when ing.TotIngressiCasino is null then null else 1 end) as TotConIngresso,
sum(regIn.totregimportoin) as TotEuroIn,
sum(regOut.totregimportoout) as TotEuroOut,
sum(regIn.totregimportoin)-sum(regOut.totregimportoout) as Diff,
(sum(regIn.totregimportoin)-sum(regOut.totregimportoout))/ count(distinct EventoID) as DiffPerEvento,
(sum(regIn.totregimportoin)-sum(regOut.totregimportoout))/ count(*) as DiffPerPartecipazione
*/
gm.EventoID, 
gm.Nome, 
gm.GamingDate, 
gm.CustomerID, 
gm.GoldenClubCardID, 
gm.LastName, 
gm.FirstName, 
gm.MemberTypeID, 
gm.OraRitiroCarta, 
gm.TotPartecipazioni, 
gm.PrimaPartecipazione, 
gm.UltimaPartecipazione, 
gm.Accompagnati,
gm.SectorName,
regIn.PrimaRegIn		AS EuroPrimaRegIn		, 
regIn.UltimaRegIn		AS EuroUltimaRegIn		, 
regIn.RegCountIn		AS EuroRegCountIn		, 
regIn.TotRegImportoIn	AS EuroTotRegImportoIn	, 
regOut.PrimaRegOut		AS EuroPrimaRegOut		, 
regOut.UltimaRegOut		AS EuroUltimaRegOut		, 
regOut.RegCountOut		AS EuroRegCountOut		, 
regOut.TotRegImportoOut	AS EuroTotRegImportoOut	, 
LRDregIn.PrimaRegIn		AS LRDregInPrimaRegIn		, 
LRDregIn.UltimaRegIn	AS LRDregInUltimaRegIn	, 
LRDregIn.RegCountIn		AS LRDregInRegCountIn		, 
LRDregIn.TotRegImportoIn AS LRDregInTotRegImportoIn, 
LRDregOut.PrimaRegOut	AS LRDregOutPrimaRegOut	, 
LRDregOut.UltimaRegOut	AS LRDregOutUltimaRegOut	, 
LRDregOut.RegCountOut	AS LRDregOutRegCountOut	, 
LRDregOut.TotRegImportoOut AS LRDregInTotRegImportoOut,
ing.PrimoIngressoCasino, 
ing.UltimoIngressoCasino, 
ing.TotIngressiCasino,
ass.PrimaRegIn		AS AssPrimo		, 
ass.UltimaRegIn		AS AssUltimo	, 
ass.RegCountIn		AS AssoCount		, 
ass.TotRegImportoIn AS AssTotImporto
FROM         
(
	SELECT     
	ev.EventoID, 
	ev.Nome, 
	ev.GamingDate, 
	gc.GoldenClubCardID, 
	gc.MemberTypeID, 
	GeneralPurpose.fn_UTCToLocal(1, gc.LinkTimeStampUTC) AS OraRitiroCarta,
	c.CustomerID, 
	c.LastName, 
	c.FirstName, 
	s.SectorName,
	COUNT(*) AS TotPartecipazioni, 
	MAX([Accompagnatori]) AS Accompagnati,
	GeneralPurpose.fn_UTCToLocal(1, MIN(g.TimeStampUTC)) AS PrimaPartecipazione, 
	GeneralPurpose.fn_UTCToLocal(1, MAX(g.TimeStampUTC)) AS UltimaPartecipazione
	FROM GoldenClub.tbl_PartecipazioneEventi AS g 
	INNER JOIN	GoldenClub.tbl_Members AS gc ON gc.CustomerID = g.CustomerID 
	INNER JOIN	Snoopy.tbl_Customers AS c ON c.CustomerID = g.CustomerID 
	INNER JOIN	[Marketing].[tbl_Eventi] AS ev ON ev.EventoID = g.EventoID
	INNER JOIN CasinoLayout.Sectors s ON s.SectorID = gc.SectorID
	--where ev.[DragonAndGolden] = 2
	GROUP BY ev.EventoID, 
	ev.Nome, 
	ev.GamingDate, 
	gc.GoldenClubCardID, 
	c.CustomerID, 
	c.LastName, 
	gc.MemberTypeID, 
	c.FirstName, 
	s.SectorName,
	gc.LinkTimeStampUTC
) AS gm 
LEFT OUTER JOIN
(
	SELECT     
	CustomerID, 
	GamingDate, 
	MIN(ora) AS PrimaRegIn, 
	MAX(ora) AS UltimaRegIn, COUNT(*) AS RegCountIn, 
	SUM(CAST([ImportoEuroCents] AS FLOAT) / 100 * ExchangeRate) AS TotRegImportoIn
	FROM   [Accounting].[vw_AllEuroCambi]
	GROUP BY CustomerID, GamingDate
) AS regIn ON regIn.CustomerID = gm.CustomerID AND regIn.GamingDate = gm.GamingDate 
LEFT OUTER JOIN
(
	SELECT     
	CustomerID, 
	GamingDate, 
	MIN(ora) AS PrimaRegOut, 
	MAX(ora) AS UltimaRegOut, 
	COUNT(*) AS RegCountOut, 
	SUM(CAST([ImportoEuroCents] AS FLOAT) / 100 * ExchangeRate)   AS TotRegImportoOut
	FROM   [Accounting].[vw_AllEuroTransactions]
	WHERE      [OpTypeID] in( 12,13)
	GROUP BY CustomerID, GamingDate
) AS regOut ON regOut.CustomerID = gm.CustomerID AND regOut.GamingDate = gm.GamingDate 
LEFT OUTER JOIN
(
	SELECT     CustomerID, 
	GamingDate, 
	MIN(ora) AS PrimoIngressoCasino, 
	MAX(ora) AS UltimoIngressoCasino, 
	COUNT(*) AS TotIngressiCasino
	FROM  GoldenClub.vw_AllEntrateGoldenClub
	where MemberFrom is not null --don't count non members
	GROUP BY CustomerID, GamingDate
) AS ing ON ing.CustomerID = gm.CustomerID AND ing.GamingDate = gm.GamingDate
LEFT OUTER JOIN
(
	SELECT     
	CustomerID, 
	GamingDate, 
	MIN(ora) AS PrimaRegIn, 
	MAX(ora) AS UltimaRegIn, COUNT(*) AS RegCountIn, 
	SUM(Importo) AS TotRegImportoIn
	FROM   Snoopy.vw_AllGoldenRegistrations
	WHERE  (Direction = 'CashIn')
	GROUP BY CustomerID, GamingDate, Direction
) AS LRDregIn ON LRDregIn.CustomerID = gm.CustomerID AND LRDregIn.GamingDate = gm.GamingDate 
LEFT OUTER JOIN
(
	SELECT     
	CustomerID, 
	GamingDate, 
	MIN(ora) AS PrimaRegOut, 
	MAX(ora) AS UltimaRegOut, 
	COUNT(*) AS RegCountOut, 
	SUM(Importo)  AS TotRegImportoOut
	FROM          Snoopy.vw_AllGoldenRegistrations AS AllGoldenRegistrations_1
	WHERE      (Direction = 'CashOut')
	GROUP BY CustomerID, GamingDate, Direction
) AS LRDregOut ON LRDregOut.CustomerID = gm.CustomerID AND LRDregOut.GamingDate = gm.GamingDate 
LEFT OUTER JOIN
(
	SELECT     
	CustomerID, 
	GamingDate, 
	MIN([EmissionTime]) AS PrimaRegIn, 
	MAX([EmissionTime]) AS UltimaRegIn, 
	COUNT(*) AS RegCountIn, 
	SUM(CHF) AS TotRegImportoIn--	SUM(Euro) AS TotRegImportoIn
	FROM   Snoopy.vw_AllAssegni
	GROUP BY CustomerID, GamingDate
) AS ass ON ass.CustomerID = gm.CustomerID AND ass.GamingDate = gm.GamingDate
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "gm"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "regIn"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 114
               Right = 412
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "regOut"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 206
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ing"
            Begin Extent = 
               Top = 114
               Left = 244
               Bottom = 222
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'GoldenClub', 'VIEW', N'vw_AllPartecipazioneEventi', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'GoldenClub', 'VIEW', N'vw_AllPartecipazioneEventi', NULL, NULL
GO
