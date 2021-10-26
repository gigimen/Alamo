SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AccontiMenoVersamentiEuro]
WITH SCHEMABINDING
AS
--corretto il case
SELECT  
	SourceLifeCycleID as LifeCycleID,
	sum(
		(case OpTypeID 
		when 1 then 1.0
		else -1.0
		end ) *
	Quantity * 
	Denomination) as TotEuro
from Accounting.vw_AllTransactionDenominations
where ValueTypeID = 7 --Euros
and OpTypeID in (1,4)
and DestLifeCycleID is not null
group by SourceLifeCycleID
GO
