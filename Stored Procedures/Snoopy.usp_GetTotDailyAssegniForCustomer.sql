SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Snoopy].[usp_GetTotDailyAssegniForCustomer] 
@GamingDate datetime,
@custid int,
@redeemed int,
@TotAssegni float output
AS
if not exists (select CustomerID from Snoopy.tbl_Customers where CustomerID = @custid)
begin
	raiserror('Invalid CustomerID %d specified',16,1,@custid)
	return (2)
end

if @redeemed is null or @redeemed = 0
	--we have to count both redeemed and unredeemed assegni
	select @TotAssegni = sum(CHF) from Snoopy.vw_AllAssegni
	where GamingDate = @GamingDate
	and CustomerID = @custid
else
	--we are interested only in redeemed assegni
	select @TotAssegni = sum(CHF) from Snoopy.vw_AllAssegni
	where GamingDate = @GamingDate
	and CustomerID = @custid
	and RedemCustTransID is not null
GO
