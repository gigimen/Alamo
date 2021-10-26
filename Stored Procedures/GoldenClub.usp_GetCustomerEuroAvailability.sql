SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [GoldenClub].[usp_GetCustomerEuroAvailability]
@LifeCycleID	int,
@CustID			INT,
@GoldenClubCardID INT output
AS
--corr

if @LifeCycleID is null and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	return 1
end

if @CustID is not null
begin
	--some check on the customer id
	select @GoldenClubCardID = GoldenClubCardID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is null
	if @GoldenClubCardID IS null
	begin
		raiserror('Invalid CustomerID (%d) specified or Customer is not a golden member ',16,1,@CustID)
		return 1
	end
end

declare @tillDate datetime,
		@days int,
		@ret int,
		@GamingDate datetime

select @days = cast(VarValue as int) from [GeneralPurpose].[ConfigParams]
 where VarName = 'EuroGoldenValidityDays'
if @days is null
begin
	raiserror ('Specify number of days in ConfigParams !!',16,1)
	--return 2
end


select @GamingDate = GamingDate from Accounting.tbl_LifeCycles
where LifeCycleID = @LifeCycleID

--loop thru all cambio of the last 3 days 


	--print @days


	--print @GamingDate


--now return the list of availability for the next # days

IF EXISTS (SELECT name FROM tempdb..sysobjects 
		WHERE name LIKE '#CustEuroReport%'
		)
begin
		--print 'dropping #CustEuroReport'
		drop table #CustEuroReport
end

	--create a temporary table that will hold the results of the calculation
CREATE TABLE #CustEuroReport(
		[GamingDate] [datetime] NOT NULL,
		[AvailabilityCents] [int] NOT NULL
	) ON [PRIMARY]

set @tillDate = @GamingDate + @days - 1


--declare and open a cursor to be looped for the results

set @ret = CURSOR_STATUS ('global','reg_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar)
if @ret > -3
begin
--	print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end
set @ret = 0
DECLARE reg_cursor CURSOR
   FOR
select Dt from GeneralPurpose.fn_GetDates (@GamingDate, @tillDate)
order by Dt asc

OPEN reg_cursor
FETCH NEXT FROM reg_cursor INTO @GamingDate
WHILE (@@FETCH_STATUS <> -1 and @ret = 0)
BEGIN
	
	set @tillDate = @GamingDate - @days + 1
	--get what will be the availability in the next days
	insert into #CustEuroReport	
	(GamingDate,AvailabilityCents)
	select @GamingDate as GamingDate,isNull(SUM(t.LeftToBeRedeemedCents),0) as AvailabilityCents
		from Accounting.tbl_EuroTransactions t
		inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = t.LifeCycleID
		where t.CustomerID = @CustID 
		and l.GamingDate >= @tillDate
		and t.CancelID is null
		and t.OpTypeID = 11 --count only acquisti
		
	FETCH NEXT FROM reg_cursor INTO @GamingDate
END
set @ret = CURSOR_STATUS ('global','reg_cursor')
if @ret > -3
begin
	--print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end

--return the recordset
select GamingDate,AvailabilityCents from #CustEuroReport

--drop the temporary table
IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#CustEuroReport%'
	)
begin
--	print 'dropping #CustEuroReport'
	drop table #CustEuroReport
end



return 0
GO
