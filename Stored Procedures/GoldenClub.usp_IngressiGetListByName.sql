SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [GoldenClub].[usp_IngressiGetListByName] 
@lastname varchar(256),
@firstname varchar(256)
AS


if @firstname is not null and len(@firstname) > 0
	SELECT  c.CustomerID, 
		g.IDDocumentID,
		g.CancelID,
		e.entratatimestampLoc AS ora, 
		e.entratatimestampUTC, 
		e.CardID,
		c.LastName, 
		c.FirstName,
		s.FName as SiteName,
		sec.SectorName as Sector,
		e.FK_CardEntryModeID AS EntryMode		
	FROM    Reception.tbl_CustomerIngressi e 
	INNER JOIN  Snoopy.tbl_Customers c ON c.CustomerID = e.CustomerID
	INNER JOIN  CasinoLayout.Sites s ON s.SiteID = e.SiteID
	LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = e.CustomerID
	LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
	where LastName like '''' + @lastname + '%'''
	and  FirstName like '''' + @firstname + '%'''
	AND IsUscita = 0
	order by e.entratatimestampUTC
else
	SELECT  c.CustomerID, 
		g.IDDocumentID,
		g.CancelID,
		e.entratatimestampLoc AS ora, 
		e.entratatimestampUTC, 
		e.CardID,
		c.LastName, 
		c.FirstName,
		s.FName as SiteName,
		sec.SectorName as Sector,
		e.FK_CardEntryModeID AS EntryMode
	FROM    Reception.tbl_CustomerIngressi e 
	INNER JOIN  Snoopy.tbl_Customers c ON c.CustomerID = e.CustomerID
	INNER JOIN  CasinoLayout.Sites s ON s.SiteID = e.SiteID
	LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = e.CustomerID
	LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
	where LastName like '''' + @lastname + '%'''
	AND IsUscita = 0
	order by e.entratatimestampUTC
GO
