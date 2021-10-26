SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE  VIEW [Snoopy].[vw_AllRegistrations]
WITH SCHEMABINDING
AS
SELECT 
	reg.RegID,
	reg.CustomerID,
	reg.Nota,
	cu.FirstName,
	cu.LastName,
	cu.Sesso,
	cu.BirthDate,
	cu.InsertDate AS CustInsertDate,
	cu.NrTelefono,
	cu.IdentificationID,
	sec.SectorName,
	i.GamingDate AS IdentificationGamingDate,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVtimeLoc,
	reg.StockID,
	ua.UserID,
	st.StockTypeID,
	st.Tag,
	reg.GamingDate,
	reg.TimeStampUTC,
	reg.TimeStampLoc AS ora,
	reg.CauseID,
	ide.FDescription AS transazione,
	reg.AmountSFr AS Importo,
	ide.RegistrationLimit,
	ide.ChiarimentoLimit,
	ide.Direction,
	i.IDCauseID,
	CASE reg.RegID WHEN i.RegID
		THEN 1
		ELSE 0 
	END AS CausedIdentification,
	gp.[Scadenza] AS ScadenzaGreenPass
FROM Snoopy.tbl_Registrations					reg
	INNER JOIN CasinoLayout.Stocks			st		ON st.StockID = reg.StockID
	INNER JOIN Snoopy.tbl_IDCauses				ide		ON ide.IDCauseID = reg.CauseID
	INNER JOIN Snoopy.tbl_Customers				cu		ON cu.CustomerID = reg.CustomerID
	INNER JOIN FloorActivity.tbl_UserAccesses	ua		ON reg.UserAccessID = ua.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Sectors	sec		ON sec.SectorID = cu.SectorID
	LEFT OUTER JOIN Snoopy.tbl_Identifications	i		ON cu.IdentificationID = i.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti		ch		ON ch.ChiarimentoID = i.ChiarimentoID
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = cu.CustomerID 	
	
WHERE cu.CustCancelID IS NULL
AND reg.CancelID IS NULL
--was a real registration
AND 
(
	reg.GamingDate < '1.1.2016' 
	OR
	(
		reg.GamingDate >= '1.1.2016' 
		AND (
			reg.AmountSFr >= ide.RegistrationLimit
			--cause an identification
			OR reg.RegID = i.RegID 
			)
	)
)







GO
