SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  VIEW [Snoopy].[vw_NewAssegni]
WITH SCHEMABINDING
AS
SELECT  FirstName as Nome, 
	LastName as Cognome, 
	BirthDate as DataNascita, 
	GamingDate, 
	DocType as TipoDocumento,
	ExpirationDate,
	DocNumber,
	StatoDomicilio,
	Citizenship,
	Address,
	NrAssegno,
	CentaxCode, 
	Importo,
	BankName, 
	AccountNr,
	case 
		GeneralPurpose.fn_GetGamingLocalDate2(
			InsertTimeStampUTC,
			Datediff(hh,InsertTimeStampUTC,GeneralPurpose.fn_UTCToLocal(1,InsertTimeStampUTC)),
			1 --dbo.Stocks.StockTypeID
			) when GamingDate 
		then 1
		else
			0
	end as IsDocNew,
	GeneralPurpose.fn_UTCToLocal(1,InsertTimeStampUTC) as InsertTimeLocal
	

FROM Snoopy.vw_AllAssegni
GO
