SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [GoldenClub].[vw_AlamoGoldenClub] 
--WITH SCHEMABINDING
AS
SELECT 
	gc.CustomerID,
	gc.FirstName,--[GeneralPurpose].[fn_ProperCase](gc.FirstName,default,default) as FirstName,
	gc.LastName,--[GeneralPurpose].[fn_ProperCase](gc.LastName,default,default) as LastName,
	gc.BirthDate,
	gc.GoldenClubCardID,
--	gc.PersonalCardID,
	gc.GoldenParams,
	gc.CancelDate,
	gc.MemberTypeID
FROM   GoldenClub.vw_AllGoldenAndDragonMembers gc	
WHERE --gc.CancelID is null --show only customer that did not disclaimed the membership
--and 
gc.MemberTypeID IN(2,3) --dragon o admiral
OR DATEDIFF(dd,gc.InsertTimeStampUTC,GETUTCDATE()) >= 1 -- membership only 1 day after identification
GO
