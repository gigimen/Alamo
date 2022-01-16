SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Reception].[vw_AllReceptionists]
AS
SELECT 
	[GeneralPurpose].[fn_GetGamingLocalDate2](GETDATE(),0,22) AS GamingDate, --change at 10 am for Veto position
	b.Promozioni,
	FirstName,		 
	LastName,		
	loginName,		
	EmailAddress,
	UserID,	
	UserGroupID,
	AllowedActions
FROM [CasinoLayout].[vw_AllUsersAllowedActions],
(
SELECT GeneralPurpose.GroupConcat(Promozione) AS Promozioni FROM [Marketing].[vw_PromozioniInCorso]
WHERE [ConsegnaSiteTypeID] = 2
) b
WHERE ApplicationID = 555503 
GO
