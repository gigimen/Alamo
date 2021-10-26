SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_CurrentAssegni]
WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT
	AssegnoID,
	NrAssegno,
	CentaxCode, 
	BankAccountID,
	BankName, 
	AccountNr, 
	CustomerID, 
	FirstName, 
    LastName, 
    BirthDate,
	IdentificationGamingDate,
	ColloquioGamingDate AS ChiarimentoGamingDate,
        Address, 
	DocType,
	DocNumber,
	Citizenship,
	IDDocumentID,
	NrTelefono,
	GamingDate,
	Tag,
	StockID,
	EmissionTime,
	DenoID,
	Valuta,
	Importo,
	CHF,
	ExchangeRate,
	EmissLFID,
	EmissCustTransID,
	RedemptionTime,
	RedemCustTransID,
	RedemLFID
FROM Snoopy.vw_AllAssegni
WHERE GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
		GETUTCDATE(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GETUTCDATE(),GETDATE()),
		7 --Cassa Centrale StockTypeID 
		)
ORDER BY EmissionTime
GO
