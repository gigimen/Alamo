SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [GoldenClub].[vw_AllDragonMembers]
AS
SELECT  c.CustomerID,
	c.LastName, 
	c.FirstName, 
	c.Sesso,
	c.BirthDate, 
	c.InsertDate as CustInsertDate,
	g.InsertTimeStampUTC,
	g.CancelID as GCCancelID,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) as StartUseMobileTimeStamp,
	g.SMSNumber,
	g.GoldenParams,
	case when g.GoldenParams & 2 = 2 then 1	else 0	end as SMSNumberChecked,
	case when g.GoldenParams & 1 = 1 then 1	else 0	end as SMSNumberDisabled,
	g.MemberTypeID,
	GeneralPurpose.fn_UTCToLocal(1,g.SMSNumberCheckedTimeStampUTC) as SMSNumberCheckedTimeStampLoc,
	GeneralPurpose.fn_UTCToLocal(1,g.LinkTimeStampUTC) as ConsegnaCarta,
	gc.GoldenClubCardID, 
	gc.CardStatusID,
	gcs.FDescription 	as CardStatus,
	gc.CustomerID 		as GCCustomerid,
	g.EmailAddress,
	d.ExpirationDate 	as GCExpirationDate,
	d.IDDocumentID 		as GCIDDocumentID,
	citi.FDescription 	as Citizenship 	,
	citi.NazioneID 		as CitizenshipID,
--	gc2.GoldenClubCardID 	as PersonalCardID, 
--	gc2.CardStatusID 	as PersonalCardStatusID,
--	gcs2.FDescription 	as PersonalCardStatus,
	c.NrTelefono,
	ch.ColloquioGamingDate as ColloquioGamingDate,
	ch.FormIVtimeLoc,
	c.IdentificationID,
	i.GamingDate as IdentificationGamingDate,
	case 
		when g.IDDocumentID is not null and 
	 (d.ExpirationDate < generalpurpose.fn_GetGamingLocalDate2(
		GetUTCDate(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GetUTCDate(),GetDate()),
		7 --Cassa Centrale StockTypeID 
		)
		)  then 1
		else 0
	end as IsDocExpired,
	dt.FDescription + ' ' + d.DocNumber as DocInfo,
	gc.CardTypeID,
	sec.SectorName,
	g.TotMoneyMove,
	g.RegistrationCount,
	ca.CancelDateLoc as CancelDate,
	s.FName as fromPC
FROM   GoldenClub.tbl_Members g
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
	LEFT OUTER JOIN GoldenClub.tbl_Cards gc on g.GoldenClubCardID = gc.GoldenClubCardID 
	LEFT OUTER JOIN GoldenClub.tbl_CardStatus gcs on gc.CardStatusID = gcs.CardStatusID
	LEFT OUTER JOIN Snoopy.tbl_Identifications i on i.IdentificationID = c.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_IDDocuments d on d.IDDocumentID = g.IDDocumentID
	LEFT OUTER JOIN Snoopy.tbl_IDDocTypes dt on dt.IDDocTypeID = d.IDDocTypeID
	LEFT OUTER JOIN Snoopy.tbl_Nazioni citi ON d.CitizenshipID = citi.NazioneID 
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch on ch.ChiarimentoID = i.ChiarimentoID
--	LEFT OUTER JOIN GoldenClub.Cards gc2 on g.CustomerID = gc2.CustomerID and gc2.CancelID is null
--	LEFT OUTER JOIN GoldenClub.CardStatus gcs2 on gc2.CardStatusID = gcs2.CardStatusID
	LEFT OUTER JOIN CasinoLayout.Sectors sec on sec.SectorID = g.SectorID
	LEFT OUTER JOIN FloorActivity.tbl_Cancellations ca ON ca.CancelID = g.CancelID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses ua ON ua.UserAccessID = ca.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Sites s ON s.SiteID = ua.SiteID

where c.CustCancelID is null and g.MemberTypeID = 2 --show only dragon













GO
