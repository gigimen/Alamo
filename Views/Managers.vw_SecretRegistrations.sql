SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Managers].[vw_SecretRegistrations]
WITH SCHEMABINDING
AS
select 	reg.RegID,
	reg.CustomerID,
	Snoopy.tbl_Customers.FirstName,
	Snoopy.tbl_Customers.LastName,
	Snoopy.tbl_Customers.BirthDate,
	Snoopy.tbl_Customers.NrTelefono,
	i.GamingDate as IdentificationGamingDate,
	ch.ColloquioGamingDate as ColloquioGamingDate,
	ch.FormIVtimeLoc,
	reg.StockID,
	CasinoLayout.Stocks.StockTypeID,
	CasinoLayout.Stocks.Tag,
	reg.GamingDate,
	reg.TimeStampUTC,
	reg.TimeStampUTC as ora,
	reg.CauseID,
	ide.FDescription as transazione,
	reg.AmountSFr as Importo,
	i.IDCauseID,
	case reg.RegID when i.RegID
		then 1
		else 0 
	end as CausedIdentification,
	Snoopy.tbl_Customers.CustCancelID,
	reg.CancelID

from Snoopy.tbl_Registrations reg
	inner join CasinoLayout.Stocks 
	on CasinoLayout.Stocks.StockID = reg.StockID
	inner join Snoopy.tbl_IDCauses ide
	on ide.IDCauseID = reg.CauseID
	inner join Snoopy.tbl_Customers 
	on Snoopy.tbl_Customers.CustomerID = reg.CustomerID
	left outer join Snoopy.tbl_Identifications i
	on Snoopy.tbl_Customers.IdentificationID = i.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch
	on ch.ChiarimentoID = i.ChiarimentoID













GO
