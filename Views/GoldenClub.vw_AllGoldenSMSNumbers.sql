SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  VIEW [GoldenClub].[vw_AllGoldenSMSNumbers]
WITH SCHEMABINDING
AS

SELECT [CustomerID]
      ,[LastName]
      ,[FirstName]
      ,[Sesso]
      ,[BirthDate]
      ,[CustInsertDate]
      ,[InsertTimeStampUTC]
      ,[GCCancelID]
      ,StartUseMobileTimeStamp AS StartUseMobileTimeStamp
      ,[SMSNumber]
      ,[GoldenParams]
      ,[SMSNumberChecked]
      ,[SMSNumberDisabled]
      ,[MemberTypeID]
      ,[SMSNumberCheckedTimeStampLoc]
      ,[ConsegnaCarta]
      ,[GoldenClubCardID]
      ,[CardStatusID]
      ,[CardStatus]
      ,[GCCustomerid]
      ,[EMailAddress]
      ,[GCExpirationDate]
      ,[GCIDDocumentID]
      ,[Citizenship]
      ,[CitizenshipID]
      ,[NrTelefono]
      ,[ColloquioGamingDate]
      ,[FormIVTimeLoc]
      ,[IdentificationID]
      ,[IdentificationGamingDate]
      ,[IsDocExpired]
      ,[DocInfo]
      ,[SectorName]
      ,[TotMoneyMove]
      ,[RegistrationCount]
      ,[CancelDate]
      ,[fromPC]
  FROM [GoldenClub].[vw_AllGoldenMembers]
WHERE GoldenClubCardID  IS NOT NULL AND SMSNumberChecked = 1 AND SMSNumberDisabled = 0
GO
