SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Accounting].[fn_Format_for_Sirio] (
@ContoBase	INT,
@contropartita INT,
@Importo	float,
@currency	INT,
@Gamingdate datetime
)  
RETURNS VARCHAR(1024) 
AS  
BEGIN 

/*


print   [Accounting].[fn_Format_for_Sirio] (33201,10020,100.45,0,'1.2.2019')


*/
	DECLARE 
	@descr		NVARCHAR(50),
	@cco		NVARCHAR(50),
	@data		INT,
	@i			VARCHAR(1024),
	@eurorate	FLOAT,
	@chf		float

	IF @Importo = 0
		RETURN NULL

SELECT 
      @descr = [descr]
      ,@cco = [Cco]
      ,@data =[data]
  FROM [Accounting].[tbl_SirioConti]
	WHERE [conto] = @contropartita
	AND 
		(
		( [indice] = 1 AND @Importo > 0)
		OR
		( [indice] = 2 AND @Importo < 0)
		)

	--registrazione con o senza CCO
/*
Parte record testata: (in comune a tutti i record)						
						
1	Lunghezza totale del record		4	char	(riempito con zero)	Ob.	Lunghezza del record (senza terminatore di linea)
2	Tipo di record (vedi tabella)	4	char	(riempito con zero)	Ob.	
												0048 = Registrazione contabile
												0100 = Fattura partitario debitore
												0104 = Nota di credito partitario debitori  
												0400 = Fattura partitario creditori
												0404 = Nota di credito partitario creditori
												NB. Se con centro di costi aggiungere 10 es:
												0048 = 0058, 0100 = 0110, 0104 = 0114, 0400 = 0410, 0404 = 0414
3	Numero conto base        		12	char	(riempito con blank)	Ob.	"Il numero del conto contabile determina la valuta!

Controllare nel piano conti di SiriO NT quale valuta è associata ad ogni conto.
Se conti in valuta estera indicare il valore anche del cambio e dell’importo.
NB. Tipo 0048: Per questo tipo di registrazioni se sono con iva il conto in SiriO deve essere di tipo mezzo liquido o singolo debitore/creditore. 

Tipo 0100/0110/0104/0114/0400/0410/0404/0414: Per questo tipo di registrazioni il   conto in SiriO NT deve essere di tipo riassuntivo debitori/creditori.

*/

	IF @cco IS NULL
		SET @i = '02400048' --niente cco
	ELSE
		SET @i = '03000058' --con cco
    

/*
Parte record tipo 0048: (registrazione contabile)						
						
4	Tipo partita contabile	1	char	(riempito con blank)	Ob.	"Tipo partita contabile di base
										1 = dare
										2 = avere"
5	Data registrazione		10	char	(data GG.MM.AAAA)		Ob.	
6	Giustificativo			15	char	(riempito con blank)		
7	Descrizione				60	char	(riempito con blank)	Ob.	
*/	


	SET @i = @i + CAST(@ContoBase AS VARCHAR(16)) + '       '
	If @Importo > 0 
        SET @i = @i + '1' --siamo in dare
	ELSE
		SET @i = @i + '2' --siamo in avere


	--data
	SET @i = @i + convert(VARCHAR(32), @Gamingdate, 104)
     
	 --giustificativo      
	SET @i = @i + CASE WHEN @currency = 0 THEN 'INCASSO EUR' ELSE 'INCASSO' END

	--fill with spaces up to 47 chars
	SET @i = @i + SPACE(46 - LEN(@i))

	 --giustificativo      
	SET @i = @i + @descr
	IF @data = 1
		SET @i = @i + ' ' + CONVERT(VARCHAR(32), @Gamingdate, 104)

	--fill with spaces up to 121 chars
	SET @i = @i + SPACE(121 - LEN(@i))

/*
Parte record importi:  (in comune a tutti i record)						
						
16a	Importo prenotazione di pagamento	15	char	(sep. decimale = .)	Sv.	"Importo per la prenotazione di pagamento in valuta del documento
													Se il campo ha come valore ‘zero’ tutto l’importo sarà prenotato
													(solo se il campo 16 ha come valore 3 o 4, se no viene ignorato)
													NB. vale solo per il tipo 0400, per altri tipi viene ignorato
													"
22	Importo (v.base)					15	char	(sep. decimale = .)	Ob.	"Importo registrazione in valuta base
													(Se la registrazione contiene iva l’importo comprenderà anche l’iva)"
23	Importo (v.estera)					15	char	(sep. decimale = .)	Sv.	"Importo registrazione in valuta estera
													(Se la registrazione contiene iva l’importo comprenderà anche l’iva)"
24	Cambio	15	char	(sep. decimale = .)	Sv.	Cambio, massimo 6 decimali
--	Campi per uso SiriO (blank)			27	char	(blank)		

*/
	--fill with spaces up to 136 chars
	IF @currency = 0 --EURO
	BEGIN
		--importo in chf
		SELECT @eurorate = IntRate 
		FROM Accounting.tbl_CurrencyGamingdateRates	
		WHERE CurrencyID = 0 AND GamingDate = @Gamingdate

		SET @chf = ABS(@importo) * @eurorate
		SET @i = @i + LTRIM(STR( @chf,10,2))
		SET @i = @i + SPACE(136 - LEN(@i))

		--go with euro importo
		SET @i = @i + LTRIM(STR( ABS(@importo),10,2))
		SET @i = @i + SPACE(151 - LEN(@i))

		----euro rate
		SET @i = @i + LTRIM(STR( @eurorate,4,2))

	END
    ELSE
	begin
		--importo in chf
		SET @chf = ABS(@importo)
		SET @i = @i + LTRIM(STR( @chf,10,2))
    end
	
	SET @i = @i + SPACE(193 - LEN(@i))
	        
    -- iva
	/*
Dati inerenti l'IVA:  (in comune a tutti i record)						
						
25	Numero gruppi IVA		2	char	(riempito con zero)	Ob.	"(Se la registrazione non comprende iva indicare 00)
										I campi 26, 27, 28, 29 sono da ripetere per il numero di volte indicato in questo campo.
										NB. I campi 26, 27, 28, 29 non sono da inserire se il campo è 00 (senza iva)"
						
26	Gruppo IVA				2	char	(riempito con blank)	Ob.	"Il gruppo iva da indicare è quello definito in SiriO NT 
										Ultimi due caratteri del numero index del gruppo iva "
27	Codice di impostazione	2	char	(riempito con blank)	Ob.	"10 = senza imposta
										11 = costo materiali; prestazione di servizi
										12 = investimenti; altri costi d’esercizio
										NB. Il codice 12 è solo per registrazioni partitario   creditori!   "
28	Genere calcolazione     1	char	(riempito con blank)	Ob.	"A = aliquota
										T = 100% (l’importo è composto solo da iva)
										P = prodotto indigeno"
29	Importo IVA (v.base)	15	char	(sep. decimale = .)	Ob.	"Totale IVA per il gruppo (Importo comprensivo di IVA)
										Es. campo no. 26 = 54     campo  no. 29 = 107.60 (100.00 + 7.60 IVA)"
										*/
    SET @i = @i + '00001'
        
    -- contropartite
	/*
Dati inerenti le contropartite contabili:						
						
30	Numero di contropartite contabili		3	char		Ob.	"Numero di contropartite (superiore a zero se l’importo iva non è uguale all’importo del documento, iva al 100%!)
															I campi 31, 32, 33 sono da ripetere per il numero di volte indicato in questo campo.
															Se la registrazione ha collegato registrazioni centro di costo, riempire il campo 34 con il numero delle registrazioni centri di costo e i campi 35, 36, 37, 38 per il numero di volte indicato nel campo 34."
																					
31	Contropartita contabile					12	char		Ob.	La contropartita deve essere in valuta base o nella valuta della partita base (campo no. 3)
32	Importo senza IVA (Netto)(v.Base)		15	char	(sep. decimale = .)	Ob.	Importo conto ricavi o costi netto (Senza IVA) in valuta base 
33	Importo senza IVA (Netto)(v.estera)		15	char	(sep. decimale = .)	Sv.	"Importo conto ricavi o costi netto (Senza IVA) in valuta estera (solo se il conto ricavi ha valuta estera)"
*/
    SET @i = @i + CAST(@contropartita AS VARCHAR(16))
	SET @i = @i + SPACE(210 - LEN(@i))
	SET @i = @i + LTRIM(STR( @chf,10,2))
	SET @i = @i + SPACE(240 - LEN(@i))

/*
Centro di Costo
34	Numero di registrazioni centro di costo	3	char		Cco.	"Numero di registrazione centro di costo (se il tipo registrazione è 0058, 0110, 0114, 0410 e 0414 questo campo ha valore minimo 1 e massimo 999)
															I campi 35, 36, 37, 38 sono da ripetere per il numero di volte indicato in questo campo.
						
35	Numero progetto centro costo			15	char		Cco.	Numero del progetto centro di costo (In SiriO NT deve coincidere con il numero NIP del progetto centro di costo)
36	Numero conto centro di costo			12	char		Cco.	Numero di conto del centro di costo
37	Importo (v.Base)						15	char	(sep. decimale = .)	Cco.	Importo della registrazione in valuta base, se nel campo 34 il numero è superiore a 1, la somma di tutti gli importi di questa registrazione deve essere uguale a quella indicata nel campo 32 (se il numero è 1 l'importo deve essere uguale al campo 32)
38	Importo (v.estera)						15	char	(sep. decimale = .)	Cco.	Importo della registrazione in valuta estera, se nel campo 34 il numero è superiore a 1, la somma di tutti gli importi di questa registrazione deve essere uguale a quella indicata nel campo 33 (se il numero è 1 l'importo deve essere uguale al campo 33)
*/
	IF @cco IS NOT NULL
	BEGIN
        SET @i = @i + '001' + @cco
		SET @i = @i + SPACE(258 - LEN(@i))
	    If @contropartita = 33500
		    SET @contropartita = 33220

		SET @i = @i + CAST(@contropartita AS VARCHAR(16))
		SET @i = @i + SPACE(270 - LEN(@i))

	 	SET @i = @i + LTRIM(STR( @chf,10,2))
		SET @i = @i + SPACE(300 - LEN(@i))
   
	END

	RETURN @i
END
GO
