SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [GoldenClub].[fn_GetScadenzaPremio](
@OffertaPremioID INT,
@InsertTimeStampUTC datetime = NULL
) 
returns datetime 
WITH SCHEMABINDING
as
BEGIN
/*
DECLARE @OffertaPremioID INT
SET @OffertaPremioID = 69
DECLARE @InsertTimeStampUTC DATETIME

SET @InsertTimeStampUTC =  '2014-04-13 23:25:31.563'
--PRINT GeneralPurpose.fn_UTCToLocal2(1,@InsertTimeStampUTC)
--PRINT [GeneralPurpose].[fn_GetGamingDate] (@InsertTimeStampUTC,1,default) 
*/

	DECLARE @r datetime,@PremioID INT,@PromoID INT,@ValiditaRitiro INT,@ndays INT,@ValidaAl DATETIME
    
	--se non è specificata una data calcola la scadenza da adesso
	IF @InsertTimeStampUTC IS NULL
		SET @InsertTimeStampUTC = GETUTCDATE()
		  
	--non scade mai di defualt
	SET @r = NULL
    
	SELECT 
		@PremioID				= o.PremioID,
		@ValiditaRitiro			= o.ValiditaRitiro,
		@ndays					= o.WithinNDays,
		@ValidaAl				= pro.ValidaAl,
		@PromoID				= pro.PromotionID
	FROM [Marketing].[tbl_OffertaPremi] o 
	INNER JOIN [Marketing].[tbl_Promozioni] pro ON o.PromotionID = pro.PromotionID 
	WHERE o.OffertaPremioID = @OffertaPremioID

	--ValiditaRitiro is 0=Always,1=OnTimeOnly,2=OnePerGamingDate,3=WithinNdays,4=PromotionValidity
	--print @ValiditaRitiro
	IF  @ValiditaRitiro NOT IN(0,1) --non scadono mai return null
	BEGIN
    
		if @ValiditaRitiro = 2 --'OnePerGamingDate'
			--scade lo stesso giorno dell'emissione
			SET @r = [GeneralPurpose].[fn_GetGamingDate] (@InsertTimeStampUTC,1,default) 
		ELSE if @ValiditaRitiro = 3 --'Within ' + CAST(o.WithinNDays as varchar(16)) + ' days'
		BEGIN
        
			DECLARE @giornoVincita DATETIME, @OraOrdine datetime
			
				

			SET @giornoVincita = GeneralPurpose.fn_GetGamingDate(@InsertTimeStampUTC,1,default)
			set @OraOrdine = GeneralPurpose.fn_UTCToLocal(1, @InsertTimeStampUTC) 

			--PRINT 'giorno vincita è ' + CONVERT(VARCHAR(32),@giornoVincita,103)
			--PRINT 'ora ordine è ' + CONVERT(VARCHAR(32),@OraOrdine,113)

			IF @PremioID IN(50,54) AND @PromoID = 17 --buono cena e pastadrink per avvento 2014 
			begin
				--aggiungi un giorno se entri dopo le 21 utc (22 locali)
				IF DATEPART(HOUR,@OraOrdine) >= 21 OR DATEPART(HOUR,@OraOrdine) < 11
				begin
					--aggiungi un giorno 
					--PRINT 'aggiungi un giorno'
					SET @giornoVincita = DATEADD(DAY,1,@giornoVincita)
				end			   
			END
	
			--finally add the days to calculate scadenza
			SET @r = DATEADD(DAY,@ndays - 1,@giornoVincita)
	
		END
		ELSE IF @ValiditaRitiro = 4 
				SET @r = @ValidaAl --'Fino al ' + CAST(pro.ValidaAl as varchar(16))
		
	END 
	--PRINT @r


	RETURN @r
END
GO
