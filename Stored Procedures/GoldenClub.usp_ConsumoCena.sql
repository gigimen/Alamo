SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_ConsumoCena]
@custID int,
@SiteID int,
@accomp int,
@tipocena int
AS


if @custID is null or not exists 
	(select CustomerID from GoldenClub.tbl_Members where CustomerID = @custID and CancelID is null and GoldenClubCardID is not null)
begin
	raiserror('%d is not a valid CustomerID or is not a Golden Club Member',16,1,@custID)
	return 1
end

if @tipocena is null or not exists 
	(select TipoCenaID from GoldenClub.tbl_TipoCene where TipoCenaID = @tipocena)
begin
	raiserror('%d is not a valid TipoCenaID',16,1,@tipocena)
	return 1
end
declare @TimeStampUTC datetime, @GamingDate datetime
set @TimeStampUTC = GETUTCDATE()
set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(  @TimeStampUTC,Datediff(hh,@TimeStampUTC,GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)),4) 


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ConsumoCena

BEGIN TRY  


	insert into GoldenClub.tbl_PartecipazioneCena
		(CustomerID,SiteID,Accompagnatori,TipoCenaID,InsertTimeStampUTC,GamingDate)
		VALUES(@custid,@SiteID,@accomp,@tipocena,@TimeStampUTC,@GamingDate)

/*lm 1.5.2018 il vecchio CiaoCiao
	IF @GamingDate >= '6.16.2025' --this is the starting day
	AND @tipocena = 3  --solo per i pastadrink fai il controllo

	BEGIN
		DECLARE @firstEntry DATETIME,@mins int
		SELECT @firstEntry = MIN([entratatimestampUTC]) FROM GoldenClub.Ingressi WHERE CustomerID = @custid AND GamingDate = @GamingDate

		--se non ha registrato l'ingresso o è meno di 3 ore
		set @mins = DATEDIFF(MINUTE,@firstEntry,@TimeStampUTC)
	
		IF @firstEntry IS NULL OR @mins < (
		SELECT CAST(VarValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'ScrockVisitMintimeMinutes' AND VarType = 3
		) --less than 180 minutes visit
		begin
			--if not scrock mark it
			IF GoldenClub.fn_IsGoldenParamSet (@custid,4096) = 0
			BEGIN
				INSERT INTO GoldenClub.tbl_ScrockBand ([CustomerID],FirstEntryUTC,[Scrock])	 VALUES (@custid,@firstEntry,1)
				EXECUTE GoldenClub.usp_SetGoldenParam @custid, 4096
			end
		END
		ELSE
		BEGIN
			--if scrock cancel it
			IF GoldenClub.fn_IsGoldenParamSet (@custid,4096) = 1
			begin
				INSERT INTO GoldenClub.tbl_ScrockBand ([CustomerID],FirstEntryUTC,[Scrock])	 VALUES (@custid,@firstEntry,0)
				EXECUTE GoldenClub.usp_UnsetGoldenParam @custid, 4096
			end
		END    
	END
	*/


	declare @attribs varchar(4096)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' SiteID=''' + CAST(@SiteID as varchar(32)) +
		''' Tipo=''' + FDescription +
		''' Accompagnatori=''' + CAST(@accomp as varchar(32)) + ''''
	from GoldenClub.tbl_TipoCene where TipoCenaID = @tipocena

	execute [GeneralPurpose].[usp_BroadcastMessage] 'ConsumaCena',@attribs


	
	COMMIT TRANSACTION trn_ConsumoCena

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ConsumoCena
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
