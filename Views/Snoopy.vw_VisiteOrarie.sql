SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Snoopy].[vw_VisiteOrarie]
AS
SELECT 
ISNULL(c.GamingDate,v.gamingdate )										AS gamingdate,
ISNULL(c.giorno,v.giorno)												AS giorno,
ISNULL(c.ora,v.ora)														AS ora,
ISNULL(c.Controlli,0)													as controlli,
ISNULL(v.Visite,0)														as VisiteAdmiral,
ISNULL(c.Controlli,0) + ISNULL(v.Visite,0)								as VisiteTotali,
ISNULL(c.Controlli,0) + ISNULL(v.Entrate,0)								as EntrateTotali,
ISNULL(u.numUscite,0)													as Uscite,
ISNULL(c.Controlli,0) + ISNULL(v.Entrate,0) - ISNULL(u.numUscite,0)		as Saldo


FROM
(
	SELECT  
		datepart(day,i.entratatimestampLoc) as giorno,
		datepart(hour,i.entratatimestampLoc) as ora,
		count(*) as Controlli,
		i.GamingDate
	FROM Snoopy.tbl_FasceEtaRegistrations i
	INNER JOIN [Snoopy].[tbl_VetoControls] c ON c.PK_ControllID = i.[FK_ControlID]
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	group by i.GamingDate,datepart(hour,i.entratatimestampLoc),datepart(day,i.entratatimestampLoc)

) c
FULL OUTER JOIN 
(
	SELECT  
		p.giorno,
		p.ora,
		count(distinct p.CustomerID)	as Visite,
		sum(p.numIngressi)				as Entrate,
		p.GamingDate
	from
	(

		SELECT  CustomerID,
				count(*)								as numIngressi,
				datepart(day,e.entratatimestampLoc)		as giorno,
				datepart(hour,e.entratatimestampLoc)	as ora,
				e.Gamingdate
		FROM Snoopy.tbl_CustomerIngressi e
		INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
		WHERE s.SiteTypeID = 2  --count all research done only at sesam
		group by CustomerID,gamingdate,datepart(day,e.entratatimestampLoc),
				datepart(hour,e.entratatimestampLoc)

	) p
	group by p.GamingDate,p.giorno,p.ora
) v ON v.Gamingdate = c.gamingdate and v.ora = c.ora and v.giorno = c.giorno
full outer join
(
		SELECT  count(*)								as numUscite,
				datepart(day,[TimestampLoc])			as giorno,
				datepart(hour,[TimestampLoc])			as ora,
				Gamingdate
		FROM Snoopy.tbl_Uscite 
		group by gamingdate,
				datepart(day,[TimestampLoc]),
				datepart(hour,[TimestampLoc])

) u ON u.Gamingdate = c.gamingdate and u.ora = c.ora and u.giorno = c.giorno
--order by ISNULL(c.giorno,v.giorno),ISNULL(c.ora,v.ora)



GO
