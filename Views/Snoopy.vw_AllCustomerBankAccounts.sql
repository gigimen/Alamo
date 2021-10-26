SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[vw_AllCustomerBankAccounts]
WITH SCHEMABINDING
AS
SELECT  Snoopy.tbl_Customers.CustomerID,
	Snoopy.tbl_Customers.FirstName, 
	Snoopy.tbl_Customers.LastName, 
	ba.BankAccountID, 
	ba.AccountNr, 
	ba.BankName,
	ba.BankAddress,
	ba.IBAN,
	ba.SWIFT

FROM Snoopy.tbl_CustomerBankAccounts ba
INNER JOIN Snoopy.tbl_Customers ON ba.CustomerID = Snoopy.tbl_Customers.CustomerID
where Snoopy.tbl_Customers.CustCancelID is null







GO
