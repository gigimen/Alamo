SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [GoldenClub].[usp_SendSMS]
@CustomerID int,
@sms varchar(1024),
@msg varchar(256) output
AS


if @CustomerID is null or not exists (
	select CustomerID from GoldenClub.tbl_Members 
	where 
	CustomerID = @CustomerID  
	and CancelID is null 
	and GoldenClubCardID is not null
	)
begin
	raiserror('Invalid CustomerID (%d) specified ',16,1,@CustomerID)
	return 1
end
--check id we have smsdisble flag
if exists (
	select CustomerID from GoldenClub.tbl_Members 
	where 
	CustomerID = @CustomerID  
	and GoldenParams & 1 = 1 -- SMSNumberDisabled
	)
begin
	raiserror('CustomerID (%d) has sms disabled ',16,1,@CustomerID)
	return 1
end
	
if @sms is null and LEN(@sms) = 0
begin
	raiserror('Invalid sms message specified',16,1)
	return 1
end

declare @recp varchar(256)
select  @recp = SMSNumber --+ ':' + cast(CustomerID as varchar(16))
from GoldenClub.tbl_Members where CustomerID = @CustomerID



exec [GeneralPurpose].usp_SendSMS 
		@recp,
		@sms, 
		@msg output
			

if @msg <> 'OK'
begin
	raiserror('Cannot send sms: %s',16,1,@msg)
	return 1
end	

return 0
GO
