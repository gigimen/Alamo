SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [GoldenClub].[fn_SMSCompleanno] (
@sesso 	bit,
--@weekday int,
@LastName varchar(256)
)
RETURNS varchar(512) 
AS  
BEGIN 
	declare @messaggio varchar(512)
	if @sesso = 1
		set @messaggio = 'Gent. Sig.ra ' + @Lastname + ' 
'
	else
		set @messaggio = 'Egr. Sig. ' + @Lastname + ' 
'
/*modificato il 31.8.2012 perché ora gli accompagnatori pagano 50 sfr
	set @messaggio = @messaggio + 'CAM Le augura Buon Compleanno e Le offre un invito per due persone per un pranzo o una cena con menu degno dell''occasione.
L''aspettiamo oggi oppure entro i prossimi due giorni.
Voglia cortesemente confermare la Sua presenza telefonando, dopo le 12:00, al +41916405038.'
*/

/* dal 30.12.2015 cambio messaggio: valido solo per la cena
*/
	set @messaggio = @messaggio + 'Il Cam Le augura Buon Compleanno e, per festeggiare in modo speciale l’occasione, Le offre una cena. Le ricordiamo che se vorrà, potrà farsi accompagnare da uno o più ospiti che potranno degustare con Lei il nostro ottimo menù, con un contributo speciale di soli CHF50.- per ospite.
L’aspettiamo da oggi e per i prossimi due giorni.
Voglia confermare la Sua presenza telefonando dopo le 12:00 al +41916405038
'
	return @messaggio
END
GO
