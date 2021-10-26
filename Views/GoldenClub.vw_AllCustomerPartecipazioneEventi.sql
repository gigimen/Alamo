SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [GoldenClub].[vw_AllCustomerPartecipazioneEventi]
WITH SCHEMABINDING
AS
SELECT 
	ev.EventoID,
	ev.Nome,
	ev.GamingDate,
	gc.GoldenClubCardID,
	GeneralPurpose.fn_UTCToLocal(1,gc.LinkTimeStampUTC) AS OraRitiroCarta,
	c.CustomerID,
	c.LastName, 
	c.FirstName, 
	s.SectorName,
	COUNT(*) AS TotPartecipazioni,
	GeneralPurpose.fn_UTCToLocal(1,MIN(g.TimeStampUTC)) AS PrimaPartecipazione,
	GeneralPurpose.fn_UTCToLocal(1,MAX(g.TimeStampUTC)) AS UltimaPartecipazione
FROM GoldenClub.tbl_PartecipazioneEventi g
	INNER JOIN GoldenClub.tbl_Members gc ON gc.CustomerID = g.CustomerID
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
	INNER JOIN [Marketing].[tbl_Eventi] ev ON ev.EventoID = g.EventoID
	LEFT OUTER JOIN CasinoLayout.Sectors s ON s.SectorID = gc.SectorID
	 
GROUP BY ev.EventoID,
	ev.Nome,
	ev.GamingDate,
	gc.GoldenClubCardID,
	c.CustomerID,
	c.LastName, 
	c.FirstName,
	s.SectorName,
	gc.LinkTimeStampUTC








GO
