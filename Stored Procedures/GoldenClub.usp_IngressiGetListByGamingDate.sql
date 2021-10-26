SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [GoldenClub].[usp_IngressiGetListByGamingDate] 
@gaming DATETIME 
AS
/*
declare @fromOra datetime 
declare @toOra datetime 
set @fromOra = @gaming

--remove all time information keep only date info
set @fromOra = DATEADD(hh,-DATEPART(hh,@fromOra),@fromOra)
set @fromOra = DATEADD(mi,-DATEPART(mi,@fromOra),@fromOra)
set @fromOra = DATEADD(ss,-DATEPART(ss,@fromOra),@fromOra)
set @fromOra = DATEADD(ms,-DATEPART(ms,@fromOra),@fromOra)

set @fromOra = DATEADD(hh,+9,@fromOra)
set @toOra   = DATEADD(dd,+1,@fromOra)

--print @fromOra
*/
SELECT  TOP 100 PERCENT 
	c.CustomerID, 
	g.IDDocumentID,
	g.CancelID,
	e.entratatimestampLoc AS ora, 
	e.entratatimestampUTC, 
	e.GamingDate,
	e.CardID,
	c.LastName, 
	c.FirstName,
	s.FName AS SiteName,
	sec.SectorName AS Sector,
	e.FK_CardEntryModeID AS EntryMode
	
FROM    Snoopy.tbl_CustomerIngressi e 
INNER JOIN  Snoopy.tbl_Customers c ON c.CustomerID = e.CustomerID
INNER JOIN  CasinoLayout.Sites s ON s.SiteID = e.SiteID
LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = e.CustomerID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
WHERE 
--e.entratatimestampUTC>= @fromOra and
--e.entratatimestampUTC < @toOra 
e.GamingDate = @gaming
AND IsUscita = 0
--and g.CancelID is null
ORDER BY e.entratatimestampUTC
GO
