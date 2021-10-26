SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Accounting].[usp_CashlessBalance]
(
@lfid int,
@totCaricati int OUTPUT,
@totScaricati int OUTPUT,
@cCaricati int OUTPUT,
@cScaricati int OUTPUT
)

AS
select 	@totCaricati = - isnull(sum(ImportoCents),0),
		@cCaricati = isnull(count(*),0)		 
from Accounting.vw_AllCashlessTransactions
where LifeCycleID = @lfid
and ImportoCents < 0 --cashless caricati

select 	@totScaricati = isnull(sum(ImportoCents),0),
		@cScaricati = isnull(count(*),0)	 
from Accounting.vw_AllCashlessTransactions
where LifeCycleID = @lfid
and ImportoCents > 0 --cashless scaricati
GO
GRANT EXECUTE ON  [Accounting].[usp_CashlessBalance] TO [SolaLetturaNoDanni]
GO
