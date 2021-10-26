SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Accounting].[usp_ReassignLifeCycle]
@lfid int,
@ToStockID int,
@uaid 	int
AS

declare @FromStockID int
declare @gaming datetime
select @FromStockID = StockID,@gaming = GamingDate  
from Accounting.tbl_LifeCycles where LifeCycleID = @lfid


if @FromStockID = null
begin
	raiserror('LifeCycle %d does not exists',16,1,@lfid)
	return (1)
end

--so far works only for LG tables
if (select count(*) from CasinoLayout.Stocks where StockID in(@FromStockID,@ToStockID) and StockTypeID = 1)  < 2
begin
	raiserror('Reassigning stock to Accounting.tbl_LifeCycles works only for tables',16,1,@lfid)
	return (1)
end
if exists (
	select LifeCycleSnapshotID from Accounting.tbl_Snapshots 
	where LifeCycleID = @lfid
	and SnapshotTypeID = 3 --Chiusura
	)
begin
	raiserror('LifeCycle %d is closed',16,1,@lfid)
	return (4)
end
if not exists (
	select LifeCycleID from Accounting.tbl_LifeCycles 
	where LifeCycleID = @lfid
	)
begin
	raiserror('LifeCycle %d does not exists',16,1,@lfid)
	return (5)
end
if exists (
	select LifeCycleID from Accounting.vw_AllStockLifeCycles 
	where GamingDate = (select GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @lfid)
	and StockID = @toStockID
	)
begin
	raiserror('Stock %d is already open for this GamingDate',16,1,@toStockID)
	return (5)
end
if not exists (
	select UserAccessID from FloorActivity.tbl_UserAccesses 
	where UserAccessID = @uaid
	)
begin
	raiserror('UserAccesses %d does not exists',16,1,@uaid)
	return (5)
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ReassignLifeCycle

BEGIN TRY  



	--first update lifecycle table
	update Accounting.tbl_LifeCycles
	set StockID = @toStockID
	where LifeCycleID = @lfid

	--then cancel accepttation of ripristino (if any)
	update Accounting.tbl_Transactions
	set DestLifeCycleID = null, DestTime = null,DestUserAccessID = null
	where OpTypeID = 5 --ripristino
	AND DestLifeCycleID = @lfid

	--then accept ripristino (if any) for that stock
	update Accounting.tbl_Transactions
	set DestLifeCycleID = @lfid, DestTime = GetUTCDAte(),DestUserAccessID = @uaid
	where OpTypeID = 5 --ripristino
	AND DestLifeCycleID = null
	and DestStockID = @toStockID


	/*
	in case we are changing the StockID of a lifecycle we are likely to close one
	stock and open a new one. In such a case braodcast two messages to let all clients
	know about it
	*/

	--broadcast a Chiusura message for the old StockID
	declare @LastLifeCycleID int
	select @LastLifeCycleID = LifeCycleID
	from Accounting.tbl_LifeCycles
	where StockID = @FromStockID and GamingDate in
		( 
			select max(GamingDate) from Accounting.tbl_LifeCycles
			where StockID = @FromStockID and GamingDate < @gaming
		)

	declare @attribs varchar(1024)
	select @attribs = 'StockID=''' + CAST(@FromStockID as varchar(32))  + 
			''' LifeCycleID=''' + CAST(@lfid as varchar(32)) + 
			''' StockTypeID=''' + CAST(CasinoLayout.Stocks.StockTypeID as varchar(32)) +
			''' Tag=''' + CasinoLayout.Stocks.Tag +
			''' LastLifeCycleID=''' + CAST(@LastLifeCycleID as varchar(32)) + 
			''' SnapshotTime=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](GetUTCDate()) + 
			''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@Gaming) + ''''
			from CasinoLayout.Stocks where CasinoLayout.Stocks.StockID = @FromStockID

	execute [GeneralPurpose].[usp_BroadcastMessage] 'Chiusura',@attribs


	select @LastLifeCycleID = LifeCycleID
	from Accounting.tbl_LifeCycles
	where StockID = @ToStockID and GamingDate in
		( 
			select max(GamingDate) from Accounting.tbl_LifeCycles
			where StockID = @ToStockID and GamingDate < @gaming
		)

	--broadcast an APERTURA message for the new StockID
	select @attribs = 'StockID=''' + CAST(@ToStockID as varchar(32))  + 
			''' LifeCycleID=''' + CAST(@lfid as varchar(32)) + 
			''' StockTypeID=''' + CAST(CasinoLayout.Stocks.StockTypeID as varchar(32)) +
			''' Tag=''' + CasinoLayout.Stocks.Tag +
			''' LastLifeCycleID=''' + CAST(@LastLifeCycleID as varchar(32)) + 
			''' SnapshotTime=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](GetUTCDate()) + 
			''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@Gaming) + ''''
			from CasinoLayout.Stocks where StockID = @ToStockID
	execute [GeneralPurpose].[usp_BroadcastMessage] 'Apertura',@attribs



	COMMIT TRANSACTION trn_ReassignLifeCycle

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ReassignLifeCycle
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
