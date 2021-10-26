SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Snoopy].[usp_ShouldBeIdentified]
@LastName varchar(256),
@FirstName varchar(256),
@GamingDate datetime,
@IdentifyIt int output
AS
--@IdentifyIt >= 1 must be identified, 0 otherwise
set @IdentifyIt = 0 --by default
if @GamingDate is null
begin
	raiserror('Invalid GamingDate specified',16,1)
	return 1
end
if @LastName is null or len(@LastName) = 0 or @FirstName is null or len(@FirstName) = 0
begin
	raiserror('Invalid Name specified ',16,1)
	return 1
end

declare @idDate datetime
declare @CustID int
declare @CustIsIdentificato INT,@err int


--first look for the customer in the customers table
set @CustIsIdentificato = 0 --not true by default

select 	@CustID = c.CustomerID, 
	@idDate = i.InsertTimeStampUTC
	from Snoopy.tbl_Customers c left outer join Snoopy.tbl_Identifications i on i.IdentificationID = c.IdentificationID 
	where upper(@LastName) = c.LastName and upper(@FirstName) = c.FirstName
	and CustCancelID is null
--if customer not in the list
if @CustID is null
begin
	raiserror('Customer unknown specified ',16,1)
	return 1
end
--if the identification date is present than he is identified
if @idDate is not null
	set @CustIsIdentificato = 1

--if already identified do nothing
--otherwise
declare @SommaImporti float
if @CustIsIdentificato = 0
begin
--	select @IdentifyIt = dbo.fn_IdentificationCondition(@GamingDate,@LastName,@FirstName)
	if exists 
	(
		select CustomerTransactionID from Snoopy.vw_AllCustomerTransactionDenominations
		where SourceGamingDate = @GamingDate
		and LastName = @LastName 
		and FirstName = @FirstName
		and DenoID = 42 --'Altra Valuta'
		and OpTypeId = 7 --registrazione
		and Quantity * Denomination * ExchangeRate >= 5000
	)
	begin
		print 'FIRST CASE match'
		set @IdentifyIt = 1
	end
	else
	begin
		--SECOND CASE
		--for every transaction type check if total exceeds 15000 SFr
		if exists 
			(
				select DenoID from Snoopy.vw_AllCustomerTransactionDenominations
				where SourceGamingDate = @GamingDate
				and LastName = @LastName 
				and FirstName = @FirstName
				and OpTypeId = 7 --registrazione
				group by DenoID
				having sum(Quantity * Denomination * ExchangeRate) >= 15000
			)
		begin
			print 'SECOND CASE match'
			set @IdentifyIt = 2
		end
		else
		begin
			--THIRD CASE (aka Cash Out transactions)
			--for connected transactions check if total exceeds 15000 SFr
			select @SommaImporti = sum(Quantity * Denomination * ExchangeRate)
			from Snoopy.vw_AllCustomerTransactionDenominations
			where SourceGamingDate = @GamingDate
			and LastName = @LastName 
			and FirstName = @FirstName
			and OpTypeId = 7 --registrazione
			and (
				DenoID = 63 -- Vincita Slot
				or DenoID = 9 -- Chips -> SFr,€
				or DenoID = 29 -- SFr -> € or SFr -> SFr
				or DenoID = 67 -- Cashless
				or DenoID = 91 -- Redemption Assegni
			    )
			if @SommaImporti >= 15000
			begin
				print 'THIRD CASE match'
				set @IdentifyIt = 3
			end
			else
			begin
				--FOURTH CASE (aka as Cash In Transactions)
				--for second kind of connected transactions check if total exceeds 15000 SFr
				select @SommaImporti = sum(Quantity * Denomination * ExchangeRate)
				from Snoopy.vw_AllCustomerTransactionDenominations
				where SourceGamingDate = @GamingDate
				and LastName = @LastName 
				and FirstName = @FirstName
				and OpTypeId = 7 --registrazione
				and (
					DenoID = 37 -- '€ -> Chips,SFr'
					or DenoID = 89 -- Incasso Assegni
					or DenoID = 90 -- Carte di Credito
				    )
				if @SommaImporti >= 15000
				begin
					print 'FOURTH CASE match'
					set @IdentifyIt = 4
				end
				else
					print 'NO identification'
			end
		end
	end
end
else
	print 'Already identified'

GO
