SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [ForIncasso].[usp_GetSommarioTroncSala]
 @gaming DATETIME,
 @totSfr FLOAT OUTPUT,
 @toteuro FLOAT OUTPUT
AS
/*


DECLARE @RC int
DECLARE @gaming datetime
DECLARE @totSfr float
DECLARE @toteuro float

-- TODO: Set parameter values here.
set @gaming = '1.24.2019'

EXECUTE @RC = [ForIncasso].[usp_GetSommarioTroncSala] 
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
			SELECT @totSfr = ISNULL(SUM(ValueSfr),0) 
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE [GamingDate] = @gaming AND SnapshotTypeID = 9 AND CurrencyID = 4


			SELECT @toteuro = ISNULL(SUM(Quantity*Denomination),0) 
			FROM [Accounting].[vw_AllConteggiDenominations]
			WHERE [GamingDate] = @gaming AND SnapshotTypeID = 9 AND CurrencyID = 0
GO
