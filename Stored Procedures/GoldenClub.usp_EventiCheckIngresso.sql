SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [GoldenClub].[usp_EventiCheckIngresso]
@CustID			int,
@EventoID		INT,
@NumPart		int output
AS

set @NumPart = 0


--check input values
if @CustID is null or not exists (
	select CustomerID
	from GoldenClub.tbl_Members 
	where CustomerID = @CustID 
	and CancelID is null 
	and GoldenClubCardID is not null)
begin
	raiserror('Invalid @CustID (%d) specified or Customer is not Golden Member',16,1,@CustID)
	return (1)
end


-- get gaming date
declare @gaming datetime
set @gaming = getdate()
execute @gaming = GeneralPurpose.fn_GetGamingLocalDate2 @gaming,1,7
--print @gaming


--cheak evento is scheduled for today
IF NOT EXISTS (
SELECT EventoID FROM Marketing.tbl_Eventi WHERE GamingDate = @gaming AND EventoID = @EventoID
)
begin
	raiserror('Invalid @EventoID (%d) specified or Evento not scheduled for today',16,1,@EventoID)
	return (1)
end

--check customer is enabled for eventi
if not exists(
select CustomerID 
from GoldenClub.tbl_Members 
where CustomerID = @CustID 
and GoldenParams & 32 = 32 --eventi allowed
)
begin
	raiserror('Customer (%d) non abilitato per gli eventi',16,1,@CustID)
	return (5)
end
/*
-- check if customer entered CK
if not exists (
	select CustomerID from GoldenClub.vw_AllEntrateGoldenClub
	where CustomerID = @CustID
	and GamingDate = @gaming
	)

begin
	raiserror('Il cliente deve registrarsi al SESAM',16,1)
	return (4)
end
*/


-- count if customer partecipated to event already
select @NumPart=ISNULL(Count(CustomerID),0)
FROM GoldenClub.tbl_PartecipazioneEventi
where CustomerID=@CustID  and EventoID = @EventoID


return 0
GO
