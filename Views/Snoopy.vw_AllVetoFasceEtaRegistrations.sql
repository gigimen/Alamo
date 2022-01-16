SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Snoopy].[vw_AllVetoFasceEtaRegistrations]
WITH SCHEMABINDING
AS
SELECT  s.FName AS SiteName, 
		s.SiteID,
		s.SiteTypeID,
		r.entratatimestampLoc AS ora, 
		r.entratatimestampUTC, 
		r.GamingDate, 
		e.searchString, 
		e.HitsNumber,
		e.PK_ControllID AS ControlID,
		r.FasciaEtaID,
		r.Sesso,
		r.ProvenienzaID
FROM 
Reception.tbl_FasceEtaRegistrations r
INNER JOIN Reception.tbl_VetoControls AS e ON e.PK_ControllID = r.FK_ControlID
INNER JOIN CasinoLayout.Sites s ON e.SiteId = s.SiteID








GO
