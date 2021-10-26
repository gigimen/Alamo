SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_CurrentRegistrations]
--WITH SCHEMABINDING
AS
SELECT     TOP 100 PERCENT 
 	r.RegID AS id,
	r.LastName AS cognome,
	r.FirstName AS nome,
	r.CustomerID,
	r.Tag AS cassa,r.Nota, 
	r.CauseID,
	r.IdentificationGamingDate,
	r.Transazione,
    r.Importo,
	r.ora,
	r.GamingDate,
	r.CausedIdentification
FROM Snoopy.vw_AllRegistrations r
WHERE GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
			GETUTCDATE(),
			DATEDIFF(hh,GETUTCDATE(),GETDATE()),
			7/*cassa centrale*/
	)
ORDER BY r.LastName,r.FirstName,r.ora
GO
