SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_CurrentDepositi]
--WITH SCHEMABINDING
AS
select  DEP.Denoid,
	DEP.Fdescription,
	'Deposito' as SourceTag,
    Sum(DEP.Quantity) as Quantity,
	min(DEP.ExchangeRate) as ExchangeRate
from Snoopy.vw_AllDepositi
inner join Snoopy.vw_AllCustomerTransactionDenominations DEP
on vw_AllDepositi.DepOnTransID = DEP.CustomerTransactionID
where depoffid is null
group by DEP.Denoid,DEP.Fdescription








GO
