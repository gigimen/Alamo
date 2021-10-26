SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_CheckConsegnaPromozione]
@CustID 		int,
@PromotionID	int,
@PremioID		int,
@gamingdate		datetime
AS

--check input values
if @CustID is null or not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is null and GoldenClubCardID is not null)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not Golden or Dragon Member',16,1,@CustID)
	return (1)
end
declare @MembershipTimeStampUTC datetime,
	@promo varchar(64),
	@GoldenParams INT,
	@MemberTypeID int
	
select 
	@MembershipTimeStampUTC = MembershipTimeStampUTC,
	@GoldenParams=GoldenParams,
	@MemberTypeID=MemberTypeID
from GoldenClub.tbl_Members where CustomerID = @CustID
if @MembershipTimeStampUTC is null
begin
	raiserror('Non membership timestamp defined for CustomerID (%d)!!',16,1,@CustID)
	return (1)
end


select @promo = Promozione
from Marketing.vw_PromozioniInCorso 
where PremioID = @PremioID 
and PromotionID = @PromotionID
and @gamingdate = GamingDate

if @promo is null or LEN(@promo) = 0
begin
	raiserror('Invalid PromotionID (%d) specified or there is not such promotion today',16,1,@PromotionId)
	return (2)
end

if exists (select CustomerID from Marketing.tbl_ConsegnaPromozione 
where PremioID = @PremioID 
and PromotionID = @PromotionID
and GamingDate = @gamingdate
and CustomerID = @CustID)
begin
	raiserror('Il cliente ha già ritirato la promozione %s',16,1,@Promo)
	return (3)
end

declare @scope int
select @scope = PromotionScope  from Marketing.tbl_Promozioni where PromotionID = @PromotionID

--remember to scope  0 = GoldenOnly, 1=Golden and Dragon, 2=DragonOnly
if @scope = 0 --only active golden allowed
begin
	if @MemberTypeID <> 1 --not a golden
	begin
		raiserror('La promozione %s è riservata ai soci Golden',16,1,@Promo)
		return (4)
	end
end
else if @scope = 2 --only dragon
begin
	if @MemberTypeID <> 2 --this is not a dragon
	begin
		raiserror('La promozione %s è riservata ai soci Dragon',16,1,@Promo)
		return (5)
	end
end

--finally check that the membership is not today
if @gamingdate = [GeneralPurpose].[fn_GetGamingDate](@MembershipTimeStampUTC,1,default) --change at 9 am by default
begin
	if @MemberTypeID = 2 
		raiserror('Il cliente si è iscritto oggi al Dragon Club',16,1)
	ELSE if @MemberTypeID = 1 
		raiserror('Il cliente si è iscritto oggi al Golden Club',16,1)
	ELSE if @MemberTypeID = 3 
		raiserror('Il cliente si è iscritto oggi all''Admiral Club',16,1)
	return (6)
end

return 0
GO
