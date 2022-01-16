SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_AllFormII]
AS
    SELECT 
	i.customerID,
	i.Lastname,
	i.FirstName,
	i.BirthDate,
	i.IdentificationGamingDate,
	f2.InsertTimeStampUTC AS oraFormII,
	DATEDIFF(DAY,i.InsertTimeStampUTC,f2.InsertTimeStampUTC) AS [FormII dopo N giorni]

  FROM Giotto.Snoopy.ImmaginiFormII f2
  INNER JOIN Snoopy.vw_PersoneIdentificate i ON f2.IdentificationID = i.IdentificationID
GO
