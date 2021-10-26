SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Snoopy].[vw_ControlloSurCambioEuro]
--WITH SCHEMABINDING
 as
 select 
 r.CustomerID,
r.FirstName,
r.LastName,
r.gamingdate,
r.ora,
r.Tag,
r.Importo,
r.RegID,
r.CauseID,
r.transazione,
CAST(t.ImportoEuroCents AS FLOAT) / 100 AS Quantity,
t.OperationName,
t.ExchangeRate,
t.FrancsInRedemCents,
t.TransactionID
from Snoopy.vw_AllRegistrations r
left outer join [Accounting].[vw_AllEuroTransactions] t
on r.GamingDate = t.GamingDate
and abs(datediff(second,r.TimeStampUTC,t.InsertTimeStamp)) < 5
and t.tag = r.tag 
where r.CauseID = 15 and r.Importo >= 5000 and t.ImportoEuroCents is not null


GO
