SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [Reception].[usp_GetCustomerInfo]
@CustID			INT,
@cardID			INT
AS
/*

execute [Snoopy].[usp_IngressiGetInfo] 56176,NULL
execute [Snoopy].[usp_IngressiGetInfo] NULL,501275


*/
-- get gaming date
DECLARE @gaming DATETIME
SET @gaming = GETDATE()
SELECT @gaming = GeneralPurpose.fn_GetGamingLocalDate2 (@gaming,0,22)

/*
PRINT @gaming

DECLARE @NumEntrance int
		SELECT @NumEntrance = VisiteTotali FROM GoldenClub.vw_CKEntrancesByGamingDate
		WHERE GamingDate = @gaming
PRINT @NumEntrance
*/
--check input values
	IF @CustID IS NULL
	BEGIN
		IF @cardID IS NULL 
		BEGIN
			RAISERROR('NULL CustomerID specified',16,1,@CustID)
			RETURN (1)
		END

		SELECT @CustID = CustomerID FROM GoldenClub.tbl_Members WHERE GoldenClubCardID = @cardID AND  CancelID IS NULL 
		IF @CustID IS null
		BEGIN
			raiserror('Invalid CardID (%d) specified or Customer is not Admiral Member',16,1,@cardID)
			return (1)
		end

	END
	ELSE
	BEGIN

		IF NOT EXISTS (SELECT CustomerID FROM Snoopy.tbl_Customers WHERE CustomerID = @CustID AND CustCancelID IS NULL)
		BEGIN
			RAISERROR('Invalid CustomerID (%d) specified or Customer is not Golden Member',16,1,@CustID)
			RETURN (1)
		END
	END



	-- check if customer entered CK
SELECT 
	c.CustomerID,
	c.LastName,
	c.FirstName,
	c.BirthDate,
	c.Sesso,
	c.CustInsertDate,
	c.SectorName,
	c.[IdentificationGamingDate],
	c.FormIVTimeLoc,
	c.ColloquioGamingDate,
	c.IdentificationID,
	c.NrTelefono,
	c.GoldenClubCardID,
	c.CancelDate,
	c.GCExpirationDate,
	c.DocInfo,
	c.SMSNumber,
	c.Citizenship,
	c.StartUseMobileTimeStamp,
	c.ConsegnaCarta,
	c.EMailAddress,
	c.GCIDDocumentID,
	c.GoldenParams,
	C.ScadenzaGreenPass,
	ISNULL(a.NumEntrance,0) AS NumEntrance,
	r.Causale,
	r.[FK_RettificaRestituzioneID],
	r.[FK_DenaroTrovatoID],
	l.DocNumber			AS lastDocNumber,
	l.ExpirationDate	AS lastExpirationDate	,
	l.DocExpired		AS lastDocExpired		,
	l.Citizenship		AS lastCitizenship		,
	l.DocInfo			AS lastDocInfo			,
	l.IDDocumentID		AS lastIDDocumentID		/*,
	d.ImageBin*/
FROM Snoopy.vw_AllCustomers c
LEFT OUTER JOIN
    (
		SELECT COUNT(*) AS NumEntrance,CustomerID
		FROM [GoldenClub].[vw_AllEntrateGoldenClub]
		WHERE GamingDate = @gaming
		AND IsSesamEntrance = 1
		AND CustomerID = @CustID
		GROUP BY CustomerID
	) a ON a.CustomerID = c.CustomerID
LEFT OUTER JOIN 
	(
		SELECT MAX([PK_RestituzioneID]) AS maxRestID,CustomerID FROM [Snoopy].[vw_AllCustomerRestituizioni]
		WHERE CustomerID = @CustID AND [RestGamingDate] IS NULL AND ([NoVetoNotification] IS NULL OR [NoVetoNotification] = 0)
		GROUP BY CustomerID
	) b ON b.CustomerID = c.CustomerID
LEFT OUTER JOIN [Snoopy].[vw_AllCustomerRestituizioni] r ON r.[PK_RestituzioneID] = b.maxRestID 
LEFT OUTER JOIN [Snoopy].[vw_LastCustomerIDDocument] l ON l.CustomerID = c.CustomerID
--LEFT OUTER JOIN [Giotto].[Snoopy].[ImmaginiDocumenti] d ON d.IdDocumentID = c.GCIDDocumentID
WHERE c.CustomerID = @CustID --AND d.PageNr = 1



RETURN 0
GO
