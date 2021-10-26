SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  VIEW [Snoopy].[vw_AllNeededPepChecks]
--WITH SCHEMABINDING
AS
SELECT  reg1.OfYear AS PepCheckYear,
	reg1.CustomerID,
	reg2.GamingDate,
	reg2.FirstName,
	reg2.LastName,
	reg2.Sesso,
	reg2.BirthDate,
	reg2.CustInsertDate,
	reg2.IdentificationID,
	reg2.NrTelefono,
	reg2.SectorName,
	ide.GamingDate AS IdentificationGamingDate,
	ide.CategoriaRischio,
	idedoc.CitizenshipID,
	citi.FDescription AS Citizenship,
	GeneralPurpose.fn_UTCToLocal(1,Primo.InsertTimeStampUTC) AS oraPepCheck,
	Primo.PepCheckID,
	reg2.Importo,
	reg2.Causa,
	ch.ColloquioGamingDate,
	ch.FormIVTimeLoc,
	reg2.IdeCauseID,
	gp.[Scadenza] AS ScadenzaGreenPass
FROM
(
SELECT  OfYear,
	MIN(oraUTC) AS oraUTC,
	CustomerID
FROM Snoopy.vw_AllGamingDatePepchecks 
GROUP BY CustomerID,OfYear
) reg1
INNER JOIN Snoopy.vw_AllGamingDatePepchecks reg2 ON reg1.CustomerID = reg2.CustomerID AND reg1.oraUTC = reg2.oraUTC
INNER JOIN Snoopy.tbl_Identifications ide ON ide.IdentificationID = reg2.IdentificationID
LEFT OUTER JOIN Snoopy.tbl_IDDocuments idedoc ON idedoc.IDDocumentID = ide.IDDocumentID
LEFT OUTER JOIN Snoopy.tbl_Nazioni citi ON idedoc.CitizenshipID = citi.NazioneID 
LEFT OUTER JOIN Snoopy.tbl_Chiarimenti	ch ON ch.ChiarimentoID = ide.ChiarimentoID
LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = reg2.CustomerID 	
/*left outer join --any document that shows the citizenship would work ok
(
select CustomerID,max(CitizenshipID) as CitizenshipID
from IdDocuments 
group by CustomerID
) idedoc on idedoc.CustomerID = reg2.CustomerID
*/
LEFT OUTER JOIN Snoopy.tbl_PepChecks Primo ON Primo.CustomerID = reg1.CustomerID AND DATEPART(yy,reg2.GamingDate) = Primo.PepCheckYear
GO
