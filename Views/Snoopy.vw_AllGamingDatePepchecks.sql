SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     VIEW [Snoopy].[vw_AllGamingDatePepchecks]
--WITH SCHEMABINDING
AS
SELECT     
/*tutti le registrazioni dell'anno che superano il limite del pep-check*/
reg.TimeStampUTC AS oraUTC,
reg.GamingDate, 
DATEPART(yy,reg.GamingDate) AS OfYear,
reg.CustomerID, 
cu.FirstName, 
cu.LastName, 
cu.Sesso, 
cu.BirthDate, 
cu.InsertDate AS CustInsertDate,
cu.IdentificationID,
cu.NrTelefono,
sec.SectorName,
reg.CauseID,
reg.AmountSFr AS Importo,
ide.FDescription AS Causa,
i.IDCauseID as IdeCauseID
FROM         Snoopy.tbl_Registrations reg 
INNER JOIN   Snoopy.tbl_IDCauses ide ON ide.IDCauseID = reg.CauseID 
INNER JOIN   Snoopy.tbl_Customers  cu ON cu.CustomerID = reg.CustomerID
INNER JOIN   Snoopy.tbl_Identifications i ON cu.IdentificationID = i.IdentificationID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = cu.SectorID
WHERE     cu.CustCancelID IS NULL 
AND reg.CancelID IS NULL
AND reg.GamingDate >= '1.1.2010'
AND 
(
	reg.AmountSFr >= ide.PepCheckLimit --registration exceeds pepcheck limit
	OR (i.RegID = reg.RegID AND reg.AmountSFr>=15000 ) --per beccare anche le registrazioni denaro chips che portano a identificazione
	or (
		i.IDCauseID = 26 --la registrazione di un cliente admiral
		 and ( 
			( reg.CauseID = 15 and reg.AmountSFr>=5000)  --cambio valuta superiore 5000
			or ( reg.AmountSFr>=15000) --or > 15000 for all other CauseID
		) 
	)
)

UNION ALL

/*tutti i primi depositi dell'anno*/
SELECT 

d2.CustomerTransactionTime AS OraUTC,
d2.DepOnGamingDate AS GamingDate,
DATEPART(yy,d2.DepOnGamingDate) AS OfYear,
d2.CustomerID, 
d2.FirstName, 
d2.LastName, 
d2.Sesso, 
d2.BirthDate, 
d2.CustInsertDate,
d2.IdentificationID,
d2.NrTelefono,
d2.SectorName,
9 AS CauseID,
d2.Importo,
'Deposito' AS Causa,
9  AS IdeCauseID
FROM Snoopy.vw_AllDepositi d2
WHERE d2.DepOnGamingDate >= '1.1.2010'


UNION ALL

/*tutti le identificazioni dell'anno*/
SELECT 
i.InsertTimeStampUTC AS OraUTC,
i.GamingDate,
DATEPART(yy,i.GamingDate)  AS OfYear,
c.CustomerID, 
c.FirstName, 
c.LastName, 
c.Sesso, 
c.BirthDate, 
c.InsertDate AS CustInsertDate,
i.IdentificationID,
c.NrTelefono,
sec.SectorName,
i.IDCauseID AS CauseID,
0 AS Importo,
'Prima Identificazione' AS Causa,
i.IDCauseID as IdeCauseID
FROM  Snoopy.tbl_Identifications i  
INNER JOIN Snoopy.tbl_Customers c ON i.IdentificationID = c.IdentificationID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
WHERE   (c.CustCancelID IS NULL)
AND (
		i.IDCauseID <> 26 --exclude partecipazioni all'admiral club
		or
		(i.IDCauseID = 26 and i.GamingDate >= '7.15.2017') --come daccordo con luca antonini
)
AND i.GamingDate >= '10.15.2010'
GO
