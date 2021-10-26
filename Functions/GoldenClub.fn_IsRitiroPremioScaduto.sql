SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [GoldenClub].[fn_IsRitiroPremioScaduto](
@OffertaPremioID int,
@ritiroPremioTimeUTC DATETIME = NULL
) 
returns bit 
WITH SCHEMABINDING
as
BEGIN
/*
DECLARE @OffertaPremioID INT
SET @OffertaPremioID = 6
DECLARE @ritiroPremioTimeUTC DATETIME

SET @ritiroPremioTimeUTC = '12.30.2013 18:00'
*/
	DECLARE @r BIT,@PremioID INT,@ValiditaRitiro INT,@ndays INT,@ValidaAl datetime
        
	--set scaduto di default
	SET @r = 1
	SELECT 
		@PremioID = o.PremioID,
		@ValiditaRitiro = o.ValiditaRitiro,
		@ndays = o.WithinNDays,
		@ValidaAl = pro.ValidaAl
	FROM [Marketing].[tbl_OffertaPremi] o 
	INNER JOIN [Marketing].[tbl_Promozioni] pro ON o.PromotionID = pro.PromotionID 
	WHERE o.OffertaPremioID =  @OffertaPremioID
	--print @ValiditaRitiro
	if @ValiditaRitiro = 0 -- 'Forever'
	or @ValiditaRitiro = 1 -- 'OneTimeOnly'
		SET @r = 0 --non ha scadenza

	ELSE if @ValiditaRitiro = 2 -- 'OnePerGamingDate'
	--controlla che sia nello stesso GamingDate
	BEGIN 
		if [GeneralPurpose].[fn_GetGamingDate] (@ritiroPremioTimeUTC,1,default) = 
		   [GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default)  
			SET @r = 0
	END	
	ELSE if @ValiditaRitiro = 3 --'Within ' + CAST(o.WithinNDays as varchar(16)) + ' days'
	BEGIN 
		DECLARE @giornoVincita DATETIME 			
		SET @giornoVincita = GeneralPurpose.fn_GetGamingDate(@ritiroPremioTimeUTC,1,default)
		--PRINT @giornoVincita
		--sono trascorsi già o.WithinNDays giorni?
		
		--nel caso dell'avvento se i buoni cena/pasta drink sono dati dopo le 22 aggiungere un giorno in piú
		IF @PremioID IN (50,54)
		BEGIN
			--check the time  
			
			--PRINT 'correct time'


			--aggiungi un giorno se entri dopo le 21 utc (22 locali)
			IF DATEPART(HOUR,@ritiroPremioTimeUTC) >= 21 OR  DATEPART(HOUR,@ritiroPremioTimeUTC) < 11
			begin
				--aggiungi un giorno 
				SET @giornoVincita = DATEADD(DAY,1,@giornoVincita)
			end			   	
		end  

		--PRINT [GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default) 
		IF DATEDIFF(
			DAY,
			@giornoVincita,
			[GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default) 
			) 	< @ndays 
			SET @r = 0

	END
	ELSE if @ValiditaRitiro = 4 --'Fino al ' + CAST(pro.ValidaAl as varchar(16))
	BEGIN 
		--è già passata la fine della promozione?
		if [GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default) <= @ValidaAl 		
			SET @r = 0
	END
    --PRINT @r
	RETURN @r
end
GO
