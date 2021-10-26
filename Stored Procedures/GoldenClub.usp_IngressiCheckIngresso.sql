SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [GoldenClub].[usp_IngressiCheckIngresso]
@CustID			int,
@NumEntrance	int output
AS

-- get gaming date
declare @gaming datetime
set @gaming = getdate()
select @gaming = GeneralPurpose.fn_GetGamingLocalDate2 (@gaming,0,22)

/*
PRINT @gaming

DECLARE @NumEntrance int
		SELECT @NumEntrance = VisiteTotali FROM GoldenClub.vw_CKEntrancesByGamingDate
		WHERE GamingDate = @gaming
PRINT @NumEntrance
*/
--check input values
if @CustID is null 
BEGIN
		
		raiserror('NULL CustomerID specified',16,1,@CustID)
		return (1)
END
ELSE
BEGIN



	if not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is null and GoldenClubCardID is not null)
	begin
		raiserror('Invalid CustomerID (%d) specified or Customer is not Golden Member',16,1,@CustID)
		return (1)
	end





	-- check if customer entered CK
	select @NumEntrance = COUNT(*) from Snoopy.tbl_CustomerIngressi
	where CustomerID = @CustID
	and GamingDate = @gaming
	AND IsUscita = 0

	if @NumEntrance = null
		set @NumEntrance = 0
END	
return 0
GO
