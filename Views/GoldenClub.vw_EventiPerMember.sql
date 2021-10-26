SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [GoldenClub].[vw_EventiPerMember]
WITH SCHEMABINDING
AS
SELECT     
	p.EventoID, 
	e.Nome AS NomeEvento, 
	e.GamingDate, 
	p.TimeStampUTC, 
	GeneralPurpose.fn_UTCToLocal(1, p.TimeStampUTC) AS ora, gc.GoldenClubCardID, 
    gc.CardStatusID, 
    gcs.FDescription AS CardStatus, 
    c.LastName, 
    c.FirstName, 
    c.BirthDate, 
    c.CustomerID, gc.CustomerID AS GCCustomerid, 
    c.NrTelefono, 
    g.SMSNumber, 
    g.EMailAddress, 
	g.MemberTypeID,
    --g.SMSNumberChecked, 
	gc.CardTypeID,
	CASE WHEN gc.CardTypeID = 1 THEN 1 ELSE 0 END	AS IsTemporaryCard
FROM 
	GoldenClub.tbl_PartecipazioneEventi AS p 
	INNER JOIN	Marketing.tbl_Eventi AS e ON e.EventoID = p.EventoID 
	INNER JOIN	GoldenClub.tbl_Members AS g ON g.CustomerID = p.CustomerID 
	INNER JOIN	Snoopy.tbl_Customers AS c ON c.CustomerID = g.CustomerID 
	LEFT OUTER JOIN	GoldenClub.tbl_Cards AS gc ON g.GoldenClubCardID = gc.GoldenClubCardID 
	LEFT OUTER JOIN	GoldenClub.tbl_CardStatus AS gcs ON gc.CardStatusID = gcs.CardStatusID 















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
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 230
               Bottom = 114
               Right = 402
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 288
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 222
               Left = 38
               Bottom = 330
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "gc"
            Begin Extent = 
               Top = 222
               Left = 248
               Bottom = 330
               Right = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "gcs"
            Begin Extent = 
               Top = 114
               Left = 326
               Bottom = 192
               Right = 474
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pgc"
            Begin Extent = 
               Top = 330
               Left = 38
               Bottom = 438
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         E', 'SCHEMA', N'GoldenClub', 'VIEW', N'vw_EventiPerMember', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'nd
         Begin Table = "pgcs"
            Begin Extent = 
               Top = 330
               Left = 254
               Bottom = 408
               Right = 402
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
', 'SCHEMA', N'GoldenClub', 'VIEW', N'vw_EventiPerMember', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'GoldenClub', 'VIEW', N'vw_EventiPerMember', NULL, NULL
GO
