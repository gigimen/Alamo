SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_MonthlyRegistrationCount]
--WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT 
	Lastname as cognome,
	FirstName as nome,
	datepart(month,gamingdate) as mese,
	datepart(year,gamingdate) as anno,
	count(*) as volte--,
	--sum(importo) as totale
from Snoopy.vw_AllRegistrations
group by 
	Lastname,
	FirstName,
	datepart(month,gamingdate),
	datepart(year,gamingdate)
having count(*) > 8
order by anno desc,mese desc









GO
