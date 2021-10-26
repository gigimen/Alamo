SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_NewEcashEuroTransaction]
@LifeCycleID int,
@ImportoCents int,
@ExchangeRate float,
@UserAccessID int,
@TransID int output
AS

declare @PhysicalEuros INT,@err int
set @PhysicalEuros = 0 --not dealing with fisical euros

--first some check on parameters
if @TransID is not null
begin
	raiserror('Cannot specify a Transaction ID',16,1)
	return 1
end
if @ExchangeRate is null or @ExchangeRate = 0
begin
	raiserror('Invalid ExchangeRate specified',16,1)
	return 1
end

if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 1
end



if @ImportoCents is null or @ImportoCents = 0
begin
	raiserror('Invalid Importo € specified ',16,1)
	return 1
END


declare @EcashLFID int
declare @EcashGamingDate datetime

--select last Lifcycle opened
SELECT @EcashLFID = LifeCycleID,@EcashGamingDate = GamingDate
from Accounting.vw_AllStockLifeCycles 
where StockID = 56 --ecash1
and CloseSnapshotID is null --not closed

declare @attribs varchar(1024)
declare @messageName varchar(32)
declare @SSTimeLoc datetime
declare @SSTimeUTC datetime
declare @snapID int
declare @LastLFID int



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewEcashEuroTransaction

BEGIN TRY  

	--check if we have a LifeCycleID for the ecash for the specified GamingDate
	if @EcashLFID is not null and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID and GamingDate = @EcashGamingDate)
	begin
		declare @SSTypeID int
		set @SSTypeID = 3 --Chiusura snapshottype
	
		--we have to close the lifecycle of the ecash
		exec [Accounting].[usp_CreateSnapShotXML] 
			@ECashLFID,		--@LifeCycleID		int,
			1,				--@UserAccessID		int,
			null,			--@ConfUserID			INT,
			null,			--@ConfUserGroupID	int,
			@SSTypeID,		--@SSTypeID			INT,
			NULL, 			--@values				varchar(max),
			@snapID out,	--	@SnapshotID			INT output,
			@SSTimeLoc out,	--	@SnapshotTimeLoc	datetime output,
			@SSTimeUTC out 	--	@SnapshotTimeUTC	datetime output	
	
		/*
	
	<ALAMO version='1'><MESS type='Chiusura' 
	LifeCycleID='98739' 
	LastLifeCycleID='0' 
	StockID='55' 
	StockTypeID='4' 
	GamingDate='40665.0000' 
	SnapTimeLoc='40666.1954' 
	SnapTimeUTC='40666.1120' 
	Tag='Cassa 7' 
	Value='629998.76' 
	Diff='-1.24' 
	UserID='157' 
	UserName='Lorenza Bernasconi'
	 /></ALAMO>
	*/
		--broadcast a Chiusura message
		select @messageName = FName from CasinoLayout.SnapshotTypes where SnapshotTypeID = @SSTypeID
		select @attribs =
			  'LifeCycleID=''' + CAST(@ECashLFID as varchar(32)) + 
			''' LastLifeCycleID=''0' +
			''' StockID=''' + CAST(CasinoLayout.Stocks.StockID as varchar(32))  + 
			''' StockTypeID=''' + CAST(CasinoLayout.Stocks.StockTypeID as varchar(32)) +
			''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](Accounting.tbl_LifeCycles.GamingDate) +
			''' SnapTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@SSTimeLoc) +
			''' SnapTimeUTC=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@SSTimeUTC) +
			''' Tag=''' + CasinoLayout.Stocks.Tag +
			''' Value=''0'' Diff=''0'' UserID=''1'' UserName=''Alamo'''
		from Accounting.tbl_LifeCycles
			inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = Accounting.tbl_LifeCycles.StockID
			where LifeCycleID = @ECashLFID
		execute [GeneralPurpose].[usp_BroadcastMessage] @messageName,@attribs
	
		set @LastLFID = @EcashLFID
		set @EcashLFID = null
	end
	else
		set @LastLFID = 0

	if @EcashLFID is null 
	begin
		--open a new lifecycle for ecash for the GamingDate of the stok
		select @EcashGamingDate = GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID
		execute Accounting.usp_OpenLifeCycle 56,1,null,null,@EcashLFID out,@snapID out,@EcashGamingDate out,@ssTimeLoc out,@ssTimeUTC out

	/*

	<ALAMO version='1'>
	<MESS type='Apertura' 
	LifeCycleID='98770' 
	LastLifeCycleID='98738' 
	StockID='37' 
	StockTypeID='4' 
	GamingDate='40666.0000' 
	SnapTimeLoc='40666.4525' 
	SnapTimeUTC='40666.3691' 
	Tag='Cassa 2 P' 
	Value='270000.00' Diff='0.00' UserID='234' UserName='Paola Banfi' />
	</ALAMO>
	*/
		--broadcast a APERTURA message
		select @messageName = FName from CasinoLayout.SnapshotTypes where SnapshotTypeID = 1
		select @attribs =
			  'LifeCycleID=''' + CAST(@ECashLFID as varchar(32)) + 
			''' LastLifeCycleID=''' + CAST(@LastLFID as varchar(32)) + 
			''' StockID=''' + CAST(CasinoLayout.Stocks.StockID as varchar(32))  + 
			''' StockTypeID=''' + CAST(CasinoLayout.Stocks.StockTypeID as varchar(32)) +
			''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](Accounting.tbl_LifeCycles.GamingDate) +
			''' SnapTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@SSTimeLoc) +
			''' SnapTimeUTC=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@SSTimeUTC ) +
			''' Tag=''' + CasinoLayout.Stocks.Tag +
			''' Value=''0'' Diff=''0'' UserID=''1'' UserName=''Alamo'''
		from Accounting.tbl_LifeCycles
			inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = Accounting.tbl_LifeCycles.StockID
		where LifeCycleID = @ECashLFID
		execute [GeneralPurpose].[usp_BroadcastMessage] @messageName,@attribs

	end


	if @EcashLFID is null 
	begin
		raiserror('Cannot find a valid LifeCycleID for the ecash stock',16,1)
	end




	--create a new customertransaction
	insert into Accounting.tbl_EuroTransactions
	(
		LifeCycleID,
		OpTypeID,
		ImportoEuroCents,
		ExchangeRate,
		FrancsInRedemCents,
		PhysicalEuros,
		CustomerID,
		UserAccessID
	)
	values
	(
		@EcashLFID,
		11, --cambio
		@ImportoCents, 
		@ExchangeRate,
		null,
		0, -- is not a PhysicalEuros,
		null,--@CustID,
		@UserAccessID
	)

	set @TransID = SCOPE_IDENTITY()

	COMMIT TRANSACTION trn_NewEcashEuroTransaction
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewEcashEuroTransaction		
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
return @ret
GO
