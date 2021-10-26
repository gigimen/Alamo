SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [GoldenClub].[vw_AllGoldenClubDisclaim]
AS
SELECT  GeneralPurpose.fn_UTCToLocal(1,ca.CancelDate) as CancelDate,
	si.FName fromPC,
	s.BarrierStart,
	s.CasinoName,
	g.GoldenClubCardID, 
	mt.MemberTypeID,
	mt.FDescription AS MemberType,
	cs.FDescription as CardStatus,
	g.CustomerID,
	c.LastName, 
	c.FirstName, 
	c.Sesso,
	c.BirthDate, 
	c.NrTelefono,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) as StartUseMobileTimeStamp,
	GeneralPurpose.fn_UTCToLocal(1,g.LinkTimeStampUTC) as oraRitiroCarta,
	ch.ColloquioGamingDate as ColloquioGamingDate,
	ch.FormIVtimeLoc,
	c.IdentificationID,
	i.GamingDate as IdentificationGamingDate,
	gc.CardTypeID,
	CASE WHEN gc.CardTypeID = 2 THEN 1 ELSE 0 END	as IsTemporaryCard,
	GeneralPurpose.fn_UTCToLocal(1,g.InsertTimeStampUTC ) as InsertTimeStampLoc

FROM  GoldenClub.tbl_Members g
	INNER JOIN GoldenClub.tbl_MemberTypes mt ON mt.MemberTypeID = g.MemberTypeID
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
	INNER JOIN FloorActivity.tbl_Cancellations ca ON ca.CancelID = g.CancelID
	INNER JOIN FloorActivity.tbl_UserAccesses ua ON ua.UserAccessID = ca.UserAccessID
	INNER JOIN CasinoLayout.Sites si ON si.SiteID = ua.SiteID
	LEFT OUTER JOIN GoldenClub.tbl_Cards gc on gc.GoldenClubCardID = g.GoldenClubCardID
	LEFT OUTER JOIN GoldenClub.tbl_CardStatus cs on cs.CardStatusID = gc.CardStatusID
	LEFT OUTER JOIN Snoopy.tbl_Identifications i on i.IdentificationID = c.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch on ch.ChiarimentoID = i.ChiarimentoID
    LEFT OUTER JOIN [Snoopy].[vw_VetoPlusGoldenClub] s ON s.CustomerID = g.CustomerID
where g.CancelID is not null and c.CustCancelID is null
and (s.Barrier IS NULL OR s.Barrier = 2 )






GO
