SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Snoopy].[vw_FrequentatoriAssidui]
with schemabinding
as

select 	e.CustomerID,
e.FirstName,
e.LastName,
e.BirthDate,
e.Citizenship,
	count(*) as giorni,
	datepart(mm,e.GamingDate) as Mese,
	datepart(yy,e.GamingDate) as Anno

from
(
	SELECT 
	i.CustomerID, 
	GamingDate,
	c.FirstName,
	c.LastName,
	c.BirthDate,
	domi.FDescription AS Citizenship
	FROM Snoopy.tbl_CustomerIngressi i
	inner join Snoopy.tbl_Customers c on c.CustomerID = i.CustomerID
	LEFT OUTER JOIN Snoopy.tbl_IDDocuments doc ON doc.CustomerID = i.CustomerID
	LEFT OUTER JOIN  Snoopy.tbl_Nazioni domi ON doc.CitizenshipID   = domi.NazioneID 
	WHERE IsUscita = 0 
	--solo gli ultimi 31 giorni
	and GamingDate >= dateAdd(dd,-31,getdate())
	group by i.CustomerID,GamingDate,
	c.FirstName,
	c.LastName,
	c.BirthDate,
	domi.FDescription
	--order by GamingDate 
) e
group by 
e.CustomerID,
e.FirstName,
e.LastName,
e.BirthDate,
e.Citizenship,
	datepart(month,e.GamingDate) ,
	datepart(year,e.GamingDate)
having count(*) >= 12
GO
