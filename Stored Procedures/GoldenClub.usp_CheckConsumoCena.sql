SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_CheckConsumoCena]
@custID				INT,
@IsSoloPastaDrink	BIT,
@messaggio			VARCHAR(512) output
AS


if @custID is null or not exists 
	(select CustomerID from GoldenClub.tbl_Members where CustomerID = @custID and CancelID is null and GoldenClubCardID is not null)
begin
	raiserror('%d is not a valid CustomerID or is not a Golden Club Member',16,1,@custID)
	return 1
end

declare @TimeStampUTC datetime, 
	@GamingDate datetime,
	@MembershipTimeStampUTC datetime,
	@promo varchar(64),
	@GoldenParams int,
	@GoldenClubCardID INT,
	@MemberTypeID int
	
select 
	@MembershipTimeStampUTC = MembershipTimeStampUTC,
	@GoldenParams=GoldenParams,
	@GoldenClubCardID=GoldenClubCardID ,
	@MemberTypeID=MemberTypeID
from GoldenClub.tbl_Members where CustomerID = @CustID
if @MembershipTimeStampUTC is null
begin
	raiserror('Non membership timestamp defined for CustomerID (%d)!!',16,1,@CustID)
	return (1)
end

set @TimeStampUTC = GETUTCDATE()
set @GamingDate = [GeneralPurpose].[fn_GetGamingDate](@TimeStampUTC,1,default) --change at 9 am by default 

if @GamingDate = [GeneralPurpose].[fn_GetGamingDate](@MembershipTimeStampUTC,1,default) --change at 9 am by default
begin
	if @MemberTypeID = 2
		raiserror('Il cliente si è iscritto oggi al Dragon Club',16,1)
	ELSE if @MemberTypeID = 1
		raiserror('Il cliente si è iscritto oggi al Golden Club',16,1)
	ELSE if @MemberTypeID = 3
		raiserror('Il cliente si è iscritto oggi all''Admiral Club',16,1)
	return (6)
end

set @messaggio = null
if @IsSoloPastaDrink = 1 
begin
	if exists (select CustomerID from GoldenClub.tbl_PartecipazioneCena where CustomerID = @custID and TipoCenaID=3 and GamingDate=@GamingDate )
	begin
		raiserror('Il cliente %d ha già consumato PastaDrink per oggi',16,1,@GoldenClubCardID)
		return (7)
	end	
end
else
begin	
		select @messaggio = TipoCena + ' il ' + convert(varchar(32),OraCena,105) from GoldenClub.[vw_UltimaCena]
		where CustomerID = @CustID
end

/*
IF @GamingDate >= '6.16.2025' --this is the starting day
AND @IsSoloPastaDrink = 1 
BEGIN
	DECLARE @firstEntry DATETIME,@mins int
	
	SELECT @firstEntry = MIN([entratatimestampUTC]) FROM GoldenClub.Ingressi WHERE CustomerID = @custid AND GamingDate = @GamingDate

	--se non ha registrato l'ingresso o è meno di 3 ore
	set @mins = DATEDIFF(MINUTE,@firstEntry,@TimeStampUTC)
	
	IF @firstEntry IS NULL OR @mins < (
	SELECT CAST(VarValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'ScrockVisitMintimeMinutes' AND VarType = 3
	) --less than 180 minutes visit
	begin
		SET @messaggio = 'Il cliente ' + cast (@GoldenClubCardID AS VARCHAR(16)) 
		IF @firstEntry IS NOT null
			SET @messaggio = @messaggio + ' è entrato alle ' + 
				CAST( DATEPART(HOUR,GeneralPurpose.fn_UTCToLocal2 (1,@firstEntry)) AS VARCHAR(8)) + ':' +
				CAST( DATEPART(MINUTE,GeneralPurpose.fn_UTCToLocal2 (1,@firstEntry)) AS VARCHAR(8)) + ' ed '
		SET @messaggio = @messaggio + ' ha meno di 3 ore.'
		--if not scrock mark it
		IF GoldenClub.fn_IsGoldenParamSet (@custid,4096) = 0
		BEGIN
			--yellow card
			SET @messaggio = @messaggio + ' Avvisare di marcare l''uscita'
		END
        ELSE
        BEGIN
			--red card
			SET @messaggio = @messaggio + ' DEVE ASPETTARE!!'
			raiserror(@messaggio,16,1)
			return (8)
		END
        
	END
 END

 */


IF @messaggio is null
	set @messaggio = ''

RETURN 0
GO
