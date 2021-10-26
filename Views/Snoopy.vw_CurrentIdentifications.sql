SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Snoopy].[vw_CurrentIdentifications]
--WITH SCHEMABINDING
AS
SELECT     TOP 100 PERCENT 
	r.IdentificationGamingDate,
 	r.LastName,
	r.FirstName,
	r.SiteName,
	r.IdentificationTime,
	r.Causale,
	r.Importo
FROM Snoopy.vw_PersoneIdentificate r
WHERE r.IdentificationGamingDate =    --'5.11.2019'

[generalpurpose].fn_GetGamingLocalDate2(
			GETUTCDATE(),
			DATEDIFF(hh,GETUTCDATE(),GETDATE()),
			7 --cassa centrale
	)
ORDER BY r.IdentificationTime,r.Lastname,r.Firstname














GO
