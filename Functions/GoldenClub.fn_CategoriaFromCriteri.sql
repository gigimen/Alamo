SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  FUNCTION [GoldenClub].[fn_CategoriaFromCriteri] 
(
	@c1 bit,@c2 INT,@c3 INT,@c4 int
)  
RETURNS INT
AS  
BEGIN 
	DECLARE @cat INT
	/*
	vecchia classificazione 
	--categoria +
	SELECT @cat = 
	CASE 
		WHEN @c4 = 1 AND @c1 = 0				THEN 1 --clienti vecchi ma con buone registrazioni
		WHEN @c4 = 1 AND @c1 = 1				THEN 2 --clienti nuovi con buone registrazioni
		WHEN @c4 = 2 AND @c3 <= 2				THEN 2 --clienti con registrazioni medie e frequenti di reg
		WHEN @c4 = 2 AND @c3 = 3				THEN 3 --clienti con registrazioni medie e bassa frequenza di reg
		WHEN @c4 = 3 AND @c3 = 1 AND @c2 <= 2	THEN 4 --clienti con registrazioni basse, frequenza di reg alta e visite non frequenti
		WHEN @c4 = 3 AND @c3 >= 2 AND @c3 <= 3	THEN 5 --clienti con registrazioni basse, frequenza di medio basse
		WHEN @c4 = 4 AND @c3 = 1 AND @c2 <= 2	THEN 5 --clienti con registrazioni basse, frequenza basse
												ELSE 6
	end
	*/


	SELECT @cat = 
	CASE 
		WHEN @c2 + @c3 = 2 THEN 1 --clienti nuovi/cvecchi con buone registrazioni medie
		WHEN @c2 + @c3 = 3 THEN 2 --clienti con registrazioni medie e frequenti
		WHEN @c2 + @c3 = 4 THEN 3 --clienti con registrazioni medie e bassa frequenza di reg
		WHEN @c2 + @c3 = 5 THEN 4 --clienti con registrazioni basse, frequenza di reg alta e visite non frequenti
		WHEN @c2 + @c3 = 6 THEN 5 --clienti con registrazioni basse, frequenza di medio basse
		  					ELSE 6
	end
		 
	RETURN @cat
END




GO
