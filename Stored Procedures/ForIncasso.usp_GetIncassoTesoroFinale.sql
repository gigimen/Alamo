SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [ForIncasso].[usp_GetIncassoTesoroFinale] 
@gaming			datetime
AS

/*

declare @gaming datetime

set @gaming = '3.14.2020'

execute [ForIncasso].[usp_GetIncassoTesoroFinale] @gaming

*/

if @gaming is null or @gaming = null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END


/*


declare @gaming			datetime

set @gaming = '4.26.2020'
--execute [ForIncasso].[usp_GetIncassoTesoroIniziale]   @gaming		


--*/

/*old way from centeggio
DECLARE @eurrate FLOAT,@totstocks int

declare @ChiusurTesoro as table (

		Tag					VARCHAR(32)			
		,StockTypeID		INT
		,StockID			INT
		,ConteggioID		INT
		,[DenoID]			INT
		,[DenoName]			VARCHAR(256)	
		,[ValueTypeName]	VARCHAR(256)	
		,CurrencyAcronim	VARCHAR(4)
		,[Denomination]		FLOAT
		,[Quantity]			INT
		,[ExchangeRate]		FLOAT
		,[ValueSfr]			FLOAT
		,[ConteggioTimeUTC]	DATETIME
		,[ConteggioTimeLoc]	DATETIME
		)

insert into @ChiusurTesoro 
EXECUTE [Accounting].[usp_GetAllStocksConteggi] 
	6, --conteggio finale
	@gaming , 
	@eurrate OUTPUT,
	@totstocks output


--select * from @ChiusurTesoro
SELECT 'INCASSO_TESORO_CHIUSURA_' + CurrencyAcronim AS ForIncassoTag,
SUM(Quantity * Denomination) as Amount
FROM @ChiusurTesoro
GROUP BY CurrencyAcronim
*/
/*

DECLARE @gaming DATETIME
SET @gaming = '4.26.2020'

--*/

declare @LastSnapshotTime 	datetime
--get the latest snapshot which is not an apertura 
--and has not been canceled
SELECT  @LastSnapshotTime = MAX(SnapshotTime) 
FROM  Accounting.tbl_LifeCycles lc
	INNER JOIN Accounting.tbl_Snapshots  ss
	ON lc.LifeCycleID = ss.LifeCycleID 
where 	lc.StockID = 47 AND lc.GamingDate = @gaming
	and ss.LCSnapShotCancelID is null
	AND ss.SnapshotTypeID NOT IN(1,6)  --not an apertura o conteggio chiusura
                          
if @LastSnapshotTime is null
begin
	raiserror('Incasso never opened',16,1)
	return (1)
END



SELECT 'INCASSO_TESORO_CHIUSURA_' + CurrencyAcronim AS ForIncassoTag,
SUM(Quantity * Denomination) as Amount
FROM Accounting.vw_AllSnapshotDenominations t
		where t.StockID = 47
		and t.SnapshotTimeUTC = @LastSnapshotTime
GROUP BY CurrencyAcronim
GO
