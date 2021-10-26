SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_GetXBalanceDenominations] 
@gaming datetime,
@trolleys int,
@Chiusura int,
@EuroRate float output,
@totStock float output
AS
/*


declare
@gaming datetime,
@trolleys int,
@Chiusura int,
@EuroRate float ,
@totStock float 

set @gaming = '5.9.2017'
set @trolleys = 1
set @Chiusura = 1
--*/
--PRINT 'Main stock gaming date is ' + convert(varchar(32),@gaming,113)

--get euro rate for that GamingDate
select @EuroRate = IntRate
from Accounting.tbl_CurrencyGamingdateRates
where CurrencyID= 0 --Euro
and GamingDate = @gaming
if @EuroRate is null
begin
	raiserror('cannot get Euro rate for the specified GamingDate',16,1)
	return(1)		
END


if @trolleys is null or @trolleys = 0
begin --main stock and riserva
	if @Chiusura is null or @Chiusura = 0 --apertura main stock
	begin
		--first make sure tha main stock has been open that gaming date
		if not exists (select LifeCycleID from Accounting.tbl_LifeCycles where StockID = 31 and GamingDate = @gaming)
		begin
			raiserror('Main stock has not been open the specified gaming date',16,1)
			return(1)		
		END
        

		--this temporary table stores all last chiusure
		--life cycles informations for main stock and riserva
		IF EXISTS (SELECT name FROM tempdb..sysobjects 
			WHERE name LIKE '#MainStockLastChiusuraValues%'
			)
		begin
			--print 'dropping #MainStockLastChiusuraValues'
			DROP TABLE #MainStockLastChiusuraValues
		END
        
		--get last close lifecycle id for Main Stock and riserva
		SELECT  st.Tag,
			st.StockID,
			st.StockTypeID,
			LCSS.LastCloseGamingDate	AS LastGamingDate,
			LCS.LifeCycleID  		AS LastCloseLifeCycleID, 
			LCS.LifeCycleSnapshotID  	AS LastCloseSnapshotID, 
			LCS.SnapshotTimeLoc 		AS LastCloseTime
		INTO #MainStockLastChiusuraValues	
		from CasinoLayout.Stocks st
		--go first with last close
		--inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LCS
		inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LCS
		on st.StockID = LCS.StockID
		--join per StockID and last known close snapshot for each stock
		inner join (
			select StockID,max(GamingDate) as LastCloseGamingDate 
			from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
			where SS.SnapshotTypeID = 3 
			and SS.StockTypeID IN (2,6)
		                         /* (SELECT     StockTypeID
		                            FROM      CasinoLayout.StockTypes
		                            WHERE     FDescription = 'Riserva' 
					    or FDescription = 'Main Stocks') */
			and SS.GamingDate <= @gaming
			group by StockID
		) as LCSS
		on LCS.StockID = LCSS.StockID 
		and LCS.GamingDate = LCSS.LastCloseGamingDate 
		and LCS.SnapshotTypeID = 3
		Where st.StockTypeID IN (2,6)
					/*(SELECT     StockTypeID
		            FROM      CasinoLayout.StockTypes
		            WHERE     FDescription = 'Riserva' or FDescription = 'Main Stocks'
					)*/
		and  @gaming >= st.FromGamingDate 
		AND (@gaming <= st.TillGamingDate OR st.TillGamingDate IS null) 
		order by st.StockTypeID,st.StockID
		
		select 'Chiusura MainStocK&Riserva' as OperationName,
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			ExchangeRate,
			SUM(Quantity) as TotQuantity
			from #MainStockLastChiusuraValues lch
			inner join Accounting.vw_AllSnapshotDenominations ch on ch.LifeCycleSnapshotID = lch.LastCloseSnapshotID
			--forget about transazioni cassa and tran main stock
			where ch.ValueTypeID not in
						(
							12, --'Transazioni Cassa'
							14-- 'Transazioni Main Stock'
						)
		group by 
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			IsFisical,
			Denomination,
			ExchangeRate

		--get rid of temporary table
		--which is no more needed
		IF EXISTS (SELECT name FROM tempdb..sysobjects 
			WHERE name LIKE '#MainStockLastChiusuraValues%'
			)
		begin
			--print 'dropping #MainStockLastChiusuraValues'
			DROP TABLE #MainStockLastChiusuraValues
		end	
	end
	else --Chiusura
	BEGIN

		--this temporary table stores all last snapshots
		--life cycles informations for main stock and riserva
		IF EXISTS (SELECT name FROM tempdb..sysobjects 
			WHERE name LIKE '#MainStockLastSnapshotsValues%'
			)
		begin
			--print 'dropping #MainStockLastSnapshotsValues'
			DROP TABLE #MainStockLastSnapshotsValues
		END
        
		--get the latest snapshot of main stock which is either the last Conteggio 
		--uscita by capo cassiera of today or the last Chiusura (in case Capo cassiera
		--made no acconto-versamento) 
		--and has not been canceled
		--get last close lifecycle id for Main Stock and riserva
		SELECT  st.Tag, 
			st.StockID, 
			st.StockTypeID, 
			MAX(LastChiusuraSS.LifeCycleID) 	AS LastCloseLifeCycleID, 
			MAX(LastChiusuraSS.GamingDate) 		AS LastgamingDate,
			MAX(LastChiusuraSS.LifeCycleSnapshotID) AS LastCloseSnapshotID, 
			MAX(LastChiusuraSS.SnapshotTimeLoc) 	AS LastCloseTime
			INTO #MainStockLastSnapshotsValues	
			FROM    CasinoLayout.Stocks st
			LEFT OUTER JOIN Accounting.vw_AllLifeCycleNonCancelledSnapshots LastChiusuraSS
			ON LastChiusuraSS.StockID = st.StockID 
			AND 
			(
				(	--is Main stock
					st.StockTypeID = 2 /*IN(SELECT     StockTypeID
		                            FROM      CasinoLayout.StockTypes
		                            WHERE     FDescription = 'Main Stocks' ) */
		                          
					AND 
					--get last Chiusura before the date or the last 
					--conteggio uscita of the date
					(
						LastChiusuraSS.GamingDate < @gaming
						AND LastChiusuraSS.SnapshotTypeID = 3 /*IN
						(SELECT     SnapshotTypeID
			                            FROM    CasinoLayout.SnapshotTypes
			                            WHERE   FName = 'Chiusura')*/
					) 
					OR 
					(
						LastChiusuraSS.GamingDate = @gaming
					    	AND LastChiusuraSS.SnapshotTypeID = 6 /*IN
						(SELECT     SnapshotTypeID
			                            FROM    CasinoLayout.SnapshotTypes
			                            WHERE   FName = 'Conteggio Uscita')*/
					) 
				)
				or
				(	--is riserva
					st.StockTypeID = 6 /*IN
		                          (SELECT     StockTypeID
		                            FROM      CasinoLayout.StockTypes
		                            WHERE     FDescription = 'Riserva' )*/
					--get last Chiusura not including the date
					--any changes to riserva is done after the Chiusura x balance
					--is created. therefore ignore possible changes to riserva 
					--for this gaming date 
					AND LastChiusuraSS.GamingDate < @gaming
					AND LastChiusuraSS.SnapshotTypeID = 3 /*IN
						(SELECT     SnapshotTypeID
			                            FROM    CasinoLayout.SnapshotTypes
			                            WHERE   FName = 'Chiusura')*/
				) 
			)
		WHERE st.StockTypeID IN (2,6)
		                         /* (SELECT     StockTypeID
		                            FROM      CasinoLayout.StockTypes
		                            WHERE     FDescription = 'Riserva'
						or FDescription = 'Main Stocks') */
		and  @gaming >= st.FromGamingDate 
		AND (@gaming <= st.TillGamingDate OR st.TillGamingDate IS null) 
		GROUP BY st.Tag, 
			st.StockID, 
			st.StockTypeID
		ORDER BY st.StockID
		
		
		SELECT 'LastSnapshots MainStocK&Riserva' as OperationName,
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			ExchangeRate,
			SUM(Quantity) as TotQuantity
			from #MainStockLastSnapshotsValues lch
			inner join Accounting.vw_AllSnapshotDenominations ch
			on ch.LifeCycleSnapshotID = lch.LastCloseSnapshotID
			--forget about transazioni cassa and tran main stock
			where ch.ValueTypeID not in
						(
							12, --'Transazioni Cassa'
							14-- 'Transazioni Main Stock'
						)
		GROUP by 
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			ExchangeRate

		IF EXISTS (SELECT name FROM tempdb..sysobjects 
			WHERE name LIKE '#MainStockLastSnapshotsValues%'
			)
		begin
			--print 'dropping #MainStockLastSnapshotsValues'
			DROP TABLE #MainStockLastSnapshotsValues
		end
	end
end 
else  --trolleys or main trolleys
begin
	--this temporary table stores all last chiusure
	--life cycles informations for all trolleys and main trolleys
	IF EXISTS (SELECT name FROM tempdb..sysobjects 
		WHERE name LIKE '#TrolleyLastChiusuraValues%'
		)
	begin
		--print 'dropping #TrolleyLastChiusuraValues'
		DROP TABLE #TrolleyLastChiusuraValues
	end
	
	--get last close lifecycle id for each Trolley or Main trolley
	SELECT  st.Tag,
		st.StockID,
		st.StockTypeID,
		LCS.LifeCycleID  		AS LastCloseLifeCycleID, 
		LCSS.LastCloseGamingDate	AS LastGamingDate,
		LCS.LifeCycleSnapshotID  	AS LastCloseSnapshotID, 
		LCS.SnapshotTimeLoc 		AS LastCloseTime
	INTO #TrolleyLastChiusuraValues	
	from CasinoLayout.Stocks st
	--go first with last close
	--inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LCS
	inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LCS
	on st.StockID = LCS.StockID
	--join per StockID and last known close snapshot for each stock
	inner join (
		select StockID,max(GamingDate) as LastCloseGamingDate 
		from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
		where SS.SnapshotTypeID = 3 
		and SS.StockTypeID IN (4,7)
/*	                          (SELECT     StockTypeID
	                            FROM      CasinoLayout.StockTypes
	                            WHERE      FDescription = 'Trolleys' 
				    or FDescription = 'Main Trolleys') */
		and SS.GamingDate <= @gaming
		group by StockID
	) as LCSS
	on LCS.StockID = LCSS.StockID 
	and LCS.GamingDate = LCSS.LastCloseGamingDate 
	and LCS.SnapshotTypeID = 3
	WHERE st.StockTypeID IN (4,7)
	                        /*  (SELECT     StockTypeID
	                            FROM      CasinoLayout.StockTypes
	                            WHERE     FDescription = 'Trolleys' 
				    or FDescription = 'Main Trolleys')*/
	and  @gaming >= st.FromGamingDate 
	AND (@gaming <= st.TillGamingDate OR st.TillGamingDate IS null) 
	order by st.StockTypeID,st.StockID

	if @Chiusura is null or @Chiusura = 0  --apertura
	begin
		select @EuroRate = ExchangeRate
			from Accounting.vw_AllTransactionDenominations
			where ValueTypeID = 7 --ValueTypeName = 'Euro' 
			and OpTypeID = 5 --OperationName = 'Ripristino'
			and DestStockTypeID = 7 /*in 
				(
				select StockTypeID 
				from CasinoLayout.StockTypes 
				where FDescription = 'Main Trolleys'
				)*/
			and SourceGamingDate = @gaming
			
		--we want to know how all trolley will be 
		--after being ripristinated therefore we have to return 
		--all ripristino Denominations create that gaming date or still pending
		--(i.e. trolley has not been opened that gaming date)
		-- plus all last chiusure of Trolleys and Main trolleys
		select 'Ripristino' as OperationName,
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			ExchangeRate,
			SUM(Quantity) as TotQuantity
			from Accounting.vw_AllTransactionDenominations rip
			inner join #TrolleyLastChiusuraValues lch
			--look for the ripristino created for the last known Chiusura
			-- therefore we have to join on the same stock 
			on lch.StockID = rip.DestStockID 
			-- and ripristino created for the last Chiusura gaming date
			and lch.LastGamingDate = rip.SourceGamingDate
			where OpTypeID = 5 --OperationName = 'Ripristino'
			and DestStockTypeID in (4,7)
/*				(
				select StockTypeID 
				from CasinoLayout.StockTypes 
				where FDescription = 'Trolleys' 
				or FDescription = 'Main Trolleys'
				)*/
			--avoid reporting ripristions with no values
			and DenoID is not null
			group by 
				DenoID,
				ValueTypeID,
				ValueTypeName,
				FDescription,
				Denomination,
				IsFisical,
				ExchangeRate
		UNION ALL
		--all last chiusre
		select 'Chiusura' as OperationName,
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			case when ValueTypeID = 7 then @EuroRate else ExchangeRate end as ExchangeRate,
			SUM(Quantity) as TotQuantity
			from #TrolleyLastChiusuraValues lch
			inner join Accounting.vw_AllSnapshotDenominations ch
			on ch.LifeCycleSnapshotID = lch.LastCloseSnapshotID
		where DenoID is not null
		group by  
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			case when ValueTypeID = 7 then @EuroRate else ExchangeRate end
	end
	else --Chiusura 


		--we want to know how all trolley were before 
		--being ripristinated therefore we have to return 
		--all Consegna Denominations create that gaming date
		--plus all last chiusure of Trolleys and Main trolleys
		--plus all ripristinos of trolleys that where not open 
		--that gaming date
		select 'ConsegnaPerRipristino' as OperationName,
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			ExchangeRate,
			SUM(Quantity) as TotQuantity
			from #TrolleyLastChiusuraValues lch
			inner join Accounting.vw_AllTransactionDenominations con on con.SourceLifeCycleID = lch.LastCloseLifeCycleID
			where OpTypeID = 6 --OperationName = 'ConsegnaPerRipristino'
			--Consegna only for this gaming date
			and lch.LastGamingDate = @gaming
			--avoid reporting ConsegnaPerRipristino with no values
			and DenoID is not null
			--forget about transazioni cassa and tran main stock
			and con.ValueTypeID not in
						(
							12, --'Transazioni Cassa'
							14-- 'Transazioni Main Stock'
						)
			group by 
				DenoID,
				ValueTypeID,
				ValueTypeName,
				FDescription,
				Denomination,
				IsFisical,
				ExchangeRate
		union all
		--all last Chiusura including those not open this gaming date
		select 'Chiusura Trolleys' as OperationName,
			ch.DenoID,
			ch.ValueTypeID,
			ch.ValueTypeName,
			ch.FDescription,
			ch.Denomination,
			ch.IsFisical,
			ch.ExchangeRate,
			SUM(ch.Quantity) as TotQuantity
			from #TrolleyLastChiusuraValues lch
			inner join Accounting.vw_AllSnapshotDenominations ch on ch.LifeCycleSnapshotID = lch.LastCloseSnapshotID
		group by  
			ch.DenoID,
			ch.ValueTypeID,
			ch.ValueTypeName,
			ch.FDescription,
			ch.Denomination,
			ch.IsFisical,
			ch.ExchangeRate
		UNION ALL
		--all ripristinos for those torlleys not open this gaming date
		select 'Ripristinato ma non usato' as OperationName,
			DenoID,
			ValueTypeID,
			ValueTypeName,
			FDescription,
			Denomination,
			IsFisical,
			ExchangeRate,
			SUM(Quantity) as TotQuantity
			from Accounting.vw_AllTransactionDenominations rip
			inner join #TrolleyLastChiusuraValues lch
			--look for the ripristino created for the last known Chiusura
			-- therefore we have to join on the same stock 
			on lch.StockID = rip.DestStockID 
			-- and ripristino created for the last Chiusura gaming date
			and lch.LastGamingDate = rip.SourceGamingDate
			where OpTypeID = 5 --OperationName = 'Ripristino'
			and DestStockTypeID in (4,7)
				/*(
				select StockTypeID 
				from CasinoLayout.StockTypes 
				where FDescription = 'Trolleys' 
				or FDescription = 'Main Trolleys'
				)*/
			and lch.LastGamingDate < @gaming
			--avoid reporting ripristions with no values
			and DenoID is not null
			group by 
				DenoID,
				ValueTypeID,
				ValueTypeName,
				FDescription,
				Denomination,
				IsFisical,
				ExchangeRate
	--get rid of temporary table
	--which is no more needed
	IF EXISTS (SELECT name FROM tempdb..sysobjects 
		WHERE name LIKE '#TrolleyLastChiusuraValues%'
		)
	begin
		--print 'dropping #TrolleyLastChiusuraValues'
		DROP TABLE #TrolleyLastChiusuraValues
	end
end

--finally get total stock for that date
--execute Accounting.usp_GetInkassoTotalStock @gaming,@totStock OUTPUT

if @Chiusura is null or @Chiusura = 0 --apertura 
BEGIN
	--in case of apertura we have get the total stock 
	SET @Gaming = DATEADD(day,1,@Gaming)
--	EXECUTE [CasinoLayout].[usp_GetTotalStock] @Gaming,@totStock OUTPUT
END
--ELSE
--	EXECUTE [CasinoLayout].[usp_GetTotalStock] @Gaming,@totStock output
select @totStock = ISNULL(SUM(scd.InitialQty*den.Denomination),0) 
FROM CasinoLayout.[tbl_StockComposition_Stocks] scs
INNER JOIN CasinoLayout.Stocks st ON st.StockID = scs.StockID
INNER JOIN CasinoLayout.StockCompositions sc ON sc.StockCompositionID = scs.StockCompositionID
LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = scs.StockCompositionID
LEFT OUTER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = scd.DenoID
where st.StockTypeID in(2,4,6,7) 
AND scs.StartOfUseGamingDate <= @Gaming
and (scs.EndOfUseGamingDate is null or @Gaming <= scs.EndOfUseGamingDate )
GO
GRANT EXECUTE ON  [Accounting].[usp_GetXBalanceDenominations] TO [SolaLetturaNoDanni]
GO
