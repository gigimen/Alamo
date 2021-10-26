SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [GoldenClub].[vw_DistribuzioneCarte]
WITH SCHEMABINDING
AS
SELECT    'Totale membri' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL

UNION ALL

SELECT    'Membri attivi con carta' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND m.GoldenClubCardID IS NOT NULL
AND m.CancelID IS NULL

UNION ALL

SELECT    'Mai visti' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
--and m.InvitationHandedOUtTimeStampUTC IS NULL
AND m.LinkTimeStampUTC IS NULL
AND SMSNumber IS NULL
AND CancelID IS NULL

UNION ALL

SELECT 	  'Rifiuti' AS Cosa,COUNT (*)  AS Quante
FROM       GoldenClub.tbl_Members
WHERE CancelID IS NOT NULL

UNION ALL



SELECT    'Partecipazioni Golden' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND GoldenClubCardID IS NOT NULL
AND CancelID IS NULL 
--and SMSNumber is not null
AND MemberTypeID = 1 --solo golden

UNION ALL

SELECT    'Partecipazioni Dragon' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE  c.CustCancelID IS NULL
AND GoldenClubCardID IS NOT NULL 
AND CancelID IS NULL 
--and SMSNumber is not null
AND MemberTypeID = 2 --solo dragon

UNION ALL

SELECT    'Partecipazioni Admiral' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE  c.CustCancelID IS NULL
AND GoldenClubCardID IS NOT NULL 
AND CancelID IS NULL 
--and SMSNumber is not null
AND MemberTypeID = 3 --solo admiral

UNION ALL 

SELECT    'Totale partecipazioni' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE  c.CustCancelID IS NULL
AND GoldenClubCardID IS NOT NULL 
AND CancelID IS NULL 

UNION ALL

SELECT  'Nessun ingresso nell''ultimo anno' AS Cosa, COUNT(*) AS Quante
  FROM GoldenClub.tbl_Members g
LEFT OUTER JOIN 
(
SELECT i.CustomerID,COUNT(*) AS tot,
MAX(i.entratatimestampLoc) AS lastVisit
FROM Snoopy.tbl_CustomerIngressi i
WHERE IsUscita = 0
GROUP BY  i.CustomerID
) v ON v.CustomerID = g.CustomerID
WHERE g.SMSNumber IS NOT NULL AND g.GoldenClubCardID IS NOT NULL
AND GETDATE() - v.lastVisit > 365

UNION ALL


SELECT    'Lettere Consegnate' AS Cosa,COUNT (*) AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND m.StartUseMobileTimeStampUTC IS NOT NULL
AND m.CancelID IS NULL

UNION ALL

SELECT    'Partecipazioni Golden con Mobile' AS Cosa, COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND GoldenClubCardID IS NOT NULL
AND CancelID IS NULL 
--and SMSNumber is not null
AND MemberTypeID = 1
AND m.StartUseMobileTimeStampUTC IS NOT NULL

UNION ALL


SELECT    'Carte provvisorie' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Cards
WHERE     CardTypeID = 2
AND CancelID IS NULL


UNION ALL

SELECT    'Carte provvisorie in uso' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
INNER JOIN GoldenClub.tbl_Cards ca ON ca.GoldenClubCardID = m.GoldenClubCardID
WHERE   c.CustCancelID IS NULL
AND ca.CardTypeID = 2
AND m.CancelID IS NULL

UNION ALL

SELECT    'Carte provvisorie in uso (con carta definitiva)' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
INNER JOIN GoldenClub.tbl_Cards ca ON ca.GoldenClubCardID = m.GoldenClubCardID
INNER JOIN GoldenClub.tbl_Cards c2 ON c2.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND ca.CardTypeID = 2
AND m.CancelID IS NULL
AND c2.CancelID IS NULL
AND c2.CardStatusID = 2 --pronta per Consegna

UNION ALL

SELECT    'Carte da Produrre' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Cards
WHERE     CardStatusID = 4 
AND CardTypeID IN(1,3) --golden and dragon
AND CancelID IS NULL

UNION ALL

SELECT    'Carte in Produzione' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Cards
WHERE     CardStatusID = 1
AND CardTypeID IN(1,3) --golden and dragon
AND CancelID IS NULL

UNION ALL

SELECT    'Carte Smarrite/Smagnetizzate' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Cards
WHERE     CancelID IS NOT NULL

UNION ALL
SELECT    'Rifiuti dopo partecipazione' AS Cosa ,COUNT(*)  AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND     m.LinkTimeStampUTC IS NOT NULL
AND m.CancelID IS NOT NULL

UNION ALL

SELECT    'SMS abilitati ma da verificare' AS Cosa ,COUNT(*) AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND     m.LinkTimeStampUTC IS NOT NULL
AND m.CancelID IS NULL
AND       (m.GoldenParams & 2 = 0) --not Checked
AND       (m.GoldenParams & 1 = 0) --not disabled

UNION ALL

SELECT    'SMS disabilitati' AS Cosa ,COUNT(*) AS Quante
FROM      GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID
WHERE   c.CustCancelID IS NULL
AND m.CancelID IS NULL
AND (m.GoldenParams & 1 = 1) -- disable
GO
