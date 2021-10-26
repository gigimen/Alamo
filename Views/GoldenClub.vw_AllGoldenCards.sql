SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [GoldenClub].[vw_AllGoldenCards]
WITH SCHEMABINDING
AS
SELECT  
	gc.GoldenClubCardID, 
	gc.CardStatusID,
	gc.CustomerID,
	gcs.FDescription as CardStatus,
	c.LastName, 
	c.FirstName, 
	c.Sesso,
	c.BirthDate, 
	c.InsertDate as CustInsertDate,
    c.NrTelefono,
	ch.ColloquioGamingDate as ColloquioGamingDate,
	ch.FormIVtimeLoc,
	c.IdentificationID,
	i.GamingDate as IdentificationGamingDate,
	gc.CardTypeID,
	gct.Fdescription AS CardType,
	gct.IsPersonal,
	CASE WHEN gc.CardTypeID = 1 THEN 1 ELSE 0 END	as IsTemporaryCard,
	GeneralPurpose.fn_UTCToLocal(1,gc.InsertTimeStampUTC ) as InsertTimeStampLoc,
	gc.CancelID,
	ca.CancelDateLoc as CancelDate,
	case when gg.GoldenParams & 2 = 2 then 1	else 0	end as SMSNumberChecked,
	case when gg.GoldenParams & 1 = 0 then 1	else 0	end as SMSNumberDisabled,
	gg.MemberTypeID,
	gg.CancelID as GCCancelID

FROM  GoldenClub.tbl_Cards gc
	INNER JOIN GoldenClub.tbl_CardStatus gcs on gc.CardStatusID = gcs.CardStatusID
	INNER JOIN GoldenClub.tbl_CardTypes gct on gct.CardTypeID = gc.CardTypeID
	LEFT OUTER JOIN GoldenClub.tbl_Members gg on gg.CustomerID = gc.CustomerID
	LEFT OUTER JOIN Snoopy.tbl_Customers c ON c.CustomerID = gc.CustomerID
	LEFT OUTER JOIN Snoopy.tbl_Identifications i on i.IdentificationID = c.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch on ch.ChiarimentoID = i.ChiarimentoID
	LEFT OUTER JOIN FloorActivity.tbl_Cancellations ca ON ca.CancelID = gc.CancelID












GO
