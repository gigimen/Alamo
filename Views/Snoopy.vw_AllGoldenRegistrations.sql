SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  VIEW [Snoopy].[vw_AllGoldenRegistrations]
WITH SCHEMABINDING
AS
SELECT 	reg.RegID,
	reg.CustomerID,
	cu.FirstName,
	cu.LastName,
	cu.Sesso,
	cu.BirthDate,
	cu.InsertDate AS CustInsertDate,
	cu.NrTelefono,
	cu.IdentificationID,
	cu.SectorID AS GamingSectorID,
	i.Gamingdate AS IdentificationGamingDate,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVtimeLoc,
	reg.StockID,
	ua.UserID,
	st.StockTypeID,
	st.Tag,
	reg.GamingDate,
	reg.TimeStampUTC,
	reg.Nota,
	sec.SectorName,
	ide.SectorID,
	ide.IDCauseID AS RegCauseID,
	ide.Direction,
	reg.TimeStampLoc AS ora,
	reg.CauseID,
	ide.FDescription AS transazione,
	reg.AmountSFr AS Importo,ide.RegistrationLimit,
	i.IDCauseID,
	CASE reg.RegID WHEN i.RegID
		THEN 1
		ELSE 0 
	END AS CausedIdentification,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	g.EMailAddress,
	--little bug to be fixed sometime
	g.StartUseMobileTimeStampUTC AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.IDDocumentID AS GoldenIDDocumentID,
	gp.[Scadenza] AS ScadenzaGreenPass
FROM Snoopy.tbl_Registrations reg
INNER JOIN CasinoLayout.Stocks st ON st.StockID = reg.StockID
INNER JOIN Snoopy.tbl_IDCauses ide ON ide.IDCauseID = reg.CauseID
INNER JOIN Snoopy.tbl_Customers cu ON cu.CustomerID = reg.CustomerID
INNER JOIN FloorActivity.tbl_UserAccesses ua ON reg.UserAccessID = ua.UserAccessID
LEFT OUTER JOIN Snoopy.tbl_Identifications i ON cu.IdentificationID = i.IdentificationID
LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = i.ChiarimentoID
LEFT OUTER JOIN GoldenClub.tbl_Members g ON cu.CustomerID = g.CustomerID AND g.CancelID IS NULL
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = cu.SectorID 
LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = reg.CustomerID 
WHERE cu.CustCancelID IS NULL
AND reg.CancelID IS NULL




GO
