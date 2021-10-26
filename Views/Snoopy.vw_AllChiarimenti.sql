SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_AllChiarimenti]
WITH SCHEMABINDING
AS
SELECT  ch.ChiarimentoID,
	i.IdentificationID,
	i.IdCauseID, 
	i.CategoriaRischio,
	c.CustomerID,
	c.FirstName, 
	c.LastName, 
	c.BirthDate,
	c.NrTelefono,
	GeneralPurpose.fn_UTCToLocal(1,i.InsertTimeStampUTC)	as IdentificationTime,
	i.GamingDate								as IdentificationGamingDate,
	GeneralPurpose.fn_UTCToLocal(1,ch.ColloquioTimeUTC)	as ColloquioTime,
	ch.ColloquioGamingDate						as ColloquioGamingDate,
	ch.AttivitaProf,
	ch.ProvenienzaPatr,
	ch.AltreInfo,
	ch.FormIVTimeLoc,
	upper(left(cuu.FirstName,1)) + upper(left(cuu.LastName, 1)) As ColloquioUserInitials,
	cuu.FirstName + ' ' + cuu.LastName							as ColloquioResponsible,
	upper(left(fuu.FirstName,1)) + upper(left(fuu.LastName, 1)) As FormIVUserInitials,
	fuu.FirstName + ' ' + fuu.LastName							as FormIVResponsible
FROM    Snoopy.tbl_Chiarimenti ch
	inner join Snoopy.tbl_Identifications i ON ch.ChiarimentoID = i.ChiarimentoID
	inner join Snoopy.tbl_Customers c		 on c.IdentificationID = i.IdentificationID
	left outer JOIN FloorActivity.tbl_UserAccesses	cu	ON cu.UserAccessID = ch.ColloquioUserAccessID
	left outer JOIN CasinoLayout.Users	cuu		ON cu.UserID = cuu.UserID 
	left outer JOIN FloorActivity.tbl_UserAccesses	fu	ON fu.UserAccessID = ch.FormIVUserAccessID
	left outer JOIN CasinoLayout.Users	fuu		ON fu.UserID = fuu.UserID 
WHERE   (c.CustCancelID is NULL)




GO
