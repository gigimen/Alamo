SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [GoldenClub].[fn_InvitoCena] (
@InvitoID INT
)
RETURNS VARCHAR(512) 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @messaggio VARCHAR(512)

/*	SELECT i.GamingDate,c.LastName,c.Sesso
	FROM GoldenClub.InvitiCene i
	--INNER JOIN GoldenClub.Members m ON m.CustomerID = i.CustomerID
	INNER JOIN Snoopy.Customers c ON c.CustomerID = i.CustomerID
*/

	SELECT @messaggio = 'INVITO DEL ' + CONVERT(VARCHAR(32), i.Gamingdate,106) + '
' +
	CASE WHEN c.Sesso = 1 THEN 'Gent. Sig.ra '
	ELSE 'Egr. Sig. ' 
	END +
	  c.Lastname + ', le offriamo un invito per due persone ad una cena (dalle 18.00 alle 22.00)
Voglia confermarci la sua prenotazione telefonando allo 0041 91 640 50 38'
	FROM GoldenClub.tbl_InvitiCene i
	--INNER JOIN GoldenClub.Members m ON m.CustomerID = i.CustomerID
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = i.CustomerID
	WHERE i.InvitoID = @InvitoID

	RETURN @messaggio
END
GO
