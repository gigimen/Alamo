SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Marketing].[vw_AllAssegnazionePremi]
WITH SCHEMABINDING
AS
SELECT     
ord.AssegnazionePremioID, 
ord.OffertaPremioID,
ord.Multiplo,
o.PremioID, 
pre.FName				AS Premio, 
o.[ConsegnaSiteTypeID],
o.AnnuncioAlSesam,
pre.ProntaConsegna, 
pro.FDescription		AS Promozione,
pro.PromotionID,
st.FName AS ConsegnataAl,
ord.CustomerID, 
g.GoldenClubCardID, 
g.SMSNumber, 
g.GoldenParams, 
[GeneralPurpose].[fn_ProperCase](cust.FirstName,DEFAULT,DEFAULT) AS FirstName, 
[GeneralPurpose].[fn_ProperCase](cust.LastName,DEFAULT,DEFAULT) AS LastName, 
cust.Sesso, 
cust.BirthDate,
cust.CustInsertDate,
cust.IdentificationGamingDate,
cust.IdentificationID,
cust.ColloquioGamingDate,
cust.FormIVTimeLoc,
cust.NrTelefono,
case 
when pro.PromotionID = 26 then ua.FName  --per i buoni macdonald mostriamo il site dove è stato consegnato
else
	UPPER(LEFT(u.FirstName,1)) + UPPER(LEFT(u.LastName,1)) 
end AS Responsabile,
acq.AcquistoID, 
ord.RitiroSiteID,
[GeneralPurpose].fn_GetGamingDate(ord.InsertTimeStampUTC,1,DEFAULT) AS OrdineGamingDate,
GeneralPurpose.fn_UTCToLocal(1, ord.InsertTimeStampUTC) AS OraOrdine, 
GeneralPurpose.fn_UTCToLocal(1, ord.RitiratoTimeStampUTC) AS OraRitiro, 
GeneralPurpose.fn_UTCToLocal(1, ord.SmsInviatoTimeStampUTC) AS OraRicezioneAcquisto, 
GeneralPurpose.fn_UTCToLocal(1, acq.CreationTimeStampUTC)  AS OraInvioAcquisto,
cust.SectorID,
cust.SectorName,
o.ValiditaRitiro,
CASE 
WHEN o.ValiditaRitiro = 0 THEN 'Forever'
WHEN o.ValiditaRitiro = 1 THEN 'OneTimeOnly'
WHEN o.ValiditaRitiro = 2 THEN 'OnePerGamingDate'
WHEN o.ValiditaRitiro = 3 THEN 'Within ' + CAST(o.WithinNDays AS VARCHAR(16)) + ' days'
WHEN o.ValiditaRitiro = 4 THEN 'Fino al ' + CAST(pro.ValidaAl AS VARCHAR(16))
END AS ValiditaRitiroDesc,
Marketing.fn_PremioDaRitirare (ord.AssegnazionePremioID) AS DaRitirare,
[GoldenClub].[fn_IsRitiroPremioScaduto](o.OffertaPremioID, ord.InsertTimeStampUTC) AS IsRitiroPremioScaduto,
[GoldenClub].[fn_GetScadenzaPremio] (ord.OffertaPremioID,ord.InsertTimeStampUTC) AS ScadenzaRitiro,
ord.[AssigningSectorID],
sec.SectorName AS AssigninSector,
gp.[Scadenza] AS ScadenzaGreenPass

FROM Marketing.tbl_AssegnazionePremi ord 
INNER JOIN Marketing.tbl_OffertaPremi o ON ord.OffertaPremioID = o.OffertaPremioID
INNER JOIN Marketing.tbl_Premi pre ON o.PremioID = pre.PremioID 
INNER JOIN Marketing.tbl_Promozioni pro ON o.PromotionID = pro.PromotionID 
INNER JOIN [Snoopy].vw_AllCustomers cust ON ord.CustomerID = cust.CustomerID 
INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = o.[ConsegnaSiteTypeID]
INNER JOIN CasinoLayout.Sites ua on ua.SiteID = ord.InsertSiteID
LEFT OUTER JOIN CasinoLayout.Users u ON u.UserID = ord.InsertUserID
LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = cust.CustomerID 
LEFT OUTER JOIN Marketing.tbl_AcquistoPremi acq ON acq.AcquistoID = ord.AcquistoID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON ord.[AssigningSectorID] = sec.SectorID
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = cust.CustomerID 	

WHERE CancelTimeUTC IS NULL 
AND pro.ValidaDal <= GeneralPurpose.fn_GetGamingLocalDate2(GETDATE(),0,1)
AND (pro.ValidaAl IS NULL OR pro.ValidaAl >= GeneralPurpose.fn_GetGamingLocalDate2(GETDATE(),0,1) )
GO
