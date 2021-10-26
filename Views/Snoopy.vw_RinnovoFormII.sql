SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_RinnovoFormII]
AS
    SELECT 
	i.customerID,
	i.Lastname,
	i.FirstName,
	i.BirthDate,
	i.IdentificationGamingDate,
	f2.InsertTimeStampUTC AS oraFormII,
	DATEDIFF(DAY,i.InsertTimeStampUTC,f2.InsertTimeStampUTC) AS [Rinnovato dopo n giorni]
  FROM Giotto.Snoopy.ImmaginiFormII f2
  INNER JOIN Snoopy.vw_PersoneIdentificate i ON f2.IdentificationID = i.IdentificationID
  WHERE DATEPART(YEAR,f2.InsertTimeStampUTC) = 2019
  --il formII è stato inserito dopo 100 giorni dall'identificazion: è un rinnovo
  AND DATEDIFF(DAY,i.InsertTimeStampUTC,f2.InsertTimeStampUTC) > 100
GO
