SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_GetInkassoTotalStock] 
@GamingDate datetime,
@totStock float output
AS

declare
--@GamingDate datetime,
--@totStock float ,
@fromComposition bit

set @fromComposition = 1
--set @GamingDate = '2.10.2015'


if @fromComposition = 0
begin
	--this temporary table stores last Chiusura snapshots id of all tables at the specified GamingDate
	IF EXISTS (SELECT name FROM tempdb..sysobjects 
		WHERE name LIKE '#CasseStockStatus%'
		)
	begin
		print 'dropping #CasseStockStatus'
		drop table #CasseStockStatus
	end


	--go with situation of tables and store last known lifecycle for each table
	SELECT  CasinoLayout.Stocks.Tag,
		Accounting.tbl_LifeCycles.StockID,
		LLCSS.LastGamingDate,
		LLCS.LifeCycleID, 
		sum (denos.InitialQty * den.Denomination) as InitialValue
	into #CasseStockStatus
	from Accounting.tbl_LifeCycles
	inner join CasinoLayout.Stocks
	on CasinoLayout.Stocks.StockID = Accounting.tbl_LifeCycles.StockID
	--go first with last close
	inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LLCS
	on Accounting.tbl_LifeCycles.LifeCycleID = LLCS.LifeCycleID
	--join per StockID and last known close snapshot for each stock
	inner join (
		select StockID,max(GamingDate) as LastGamingDate 
		from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
		where SS.SnapshotTypeID = 1 --apertura snapshottype
		and (SS.StockTypeID in(2,4,6,7))   --cassa, main cassa main stock e riserva
		and GamingDate <= @GamingDate -- from the specified GamingDate
		group by StockID
	) as LLCSS
	on LLCS.StockID = LLCSS.StockID 
	and LLCS.GamingDate = LLCSS.LastGamingDate 
	and LLCS.SnapshotTypeID = 1 --apertura snapshottype
	--now get the composition

	INNER JOIN CasinoLayout.StockCompositions
	ON CasinoLayout.StockCompositions.StockCompositionID = Accounting.tbl_LifeCycles.StockCompositionID
	INNER JOIN CasinoLayout.StockComposition_Denominations denos
	ON CasinoLayout.StockCompositions.StockCompositionID = denos.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations den 
	ON den.DenoID = denos.DenoID

	Where CasinoLayout.Stocks.StockTypeID in(2,4,6,7)   --cassa, main cassa main stock e riserva
	and denos.InitialQty is not null

	group by CasinoLayout.Stocks.Tag,
		Accounting.tbl_LifeCycles.StockID,
		LLCSS.LastGamingDate,
		LLCS.LifeCycleID
	--order by Stocks.StockTypeID,Stocks.StockID

	select * from #CasseStockStatus
	select @totStock = sum(isnull(InitialValue,0)) from #CasseStockStatus



	--this temporary table stores last Chiusura snapshots id of all tables at the specified GamingDate
	IF EXISTS (SELECT name FROM tempdb..sysobjects 
		WHERE name LIKE '#CasseStockStatus%'
		)
	begin
		print 'dropping #CasseStockStatus'
		drop table #CasseStockStatus
	end
end
else
begin

	SELECT [StockCompositionID]
		  ,[CompName]
		  ,[CompDescription]
		  ,[Tag]
		  ,[StockID]
		  ,[StockTypeID]
		  ,[Comment]
		  ,[CreationDate]
		  ,[Totale]
	  FROM [CasinoLayout].[vw_AllStockCompositionTotals]
	  where StockTypeID in(2,4,6,7) and StartOfUseGamingDate <= @GamingDate
	  and ([EndOfUseGamingDate] is null or [EndOfUseGamingDate] >= @GamingDate)

	select @totStock = sum(isnull([Totale],0)) 
	FROM [CasinoLayout].[vw_AllStockCompositionTotals]
	  where StockTypeID in(2,4,6,7) and StartOfUseGamingDate <= @GamingDate
	  and ([EndOfUseGamingDate] is null or [EndOfUseGamingDate] >= @GamingDate)


end

select @totStock as '@totStock'
GO
