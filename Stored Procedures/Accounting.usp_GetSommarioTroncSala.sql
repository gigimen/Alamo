SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Accounting].[usp_GetSommarioTroncSala]
 @gaming datetime,
 @totSfr float output,
 @toteuro float output
AS
/*


DECLARE @RC int
DECLARE @gaming datetime
DECLARE @totSfr float
DECLARE @toteuro float

-- TODO: Set parameter values here.
set @gaming = '1.24.2019'

EXECUTE @RC = [Accounting].[usp_GetSommarioTroncSala] 
   @gaming
  ,@totSfr OUTPUT
  ,@toteuro OUTPUT

select @totSfr as 'totSfr'
select @toteuro as 'toteuro'

			SELECT *
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE [GamingDate] = @gaming and SnapshotTypeID = 9 
			order by CurrencyID

			SELECT sum(ValueSfr),sum(Quantity*Denomination),CurrencyID
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE [GamingDate] = @gaming and SnapshotTypeID = 9 
			group by CurrencyID


--*/
			SELECT @totSfr = isnull(sum(ValueSfr),0) 
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE [GamingDate] = @gaming and SnapshotTypeID = 9 AND CurrencyID = 4


			SELECT @toteuro = isnull(sum(Quantity*Denomination),0) 
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE [GamingDate] = @gaming and SnapshotTypeID = 9 and CurrencyID = 0
GO
GRANT EXECUTE ON  [Accounting].[usp_GetSommarioTroncSala] TO [SolaLetturaNoDanni]
GO
