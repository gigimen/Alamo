SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Snoopy].[fn_TorneoCheckRientro](@FK_TPGiornataID INT,@FK_CustomerID INT)
Returns int
AS
--ritorna 1 se il puo rientrare altrimenti 0
BEGIN

Declare @Count int
/*
Declare @Count int,@FK_TPGiornataID INT,@FK_CustomerID INT
	set @FK_CustomerID=44003
	set @FK_TPGiornataID=3
    
--*/
	--se la giornata e' un satellite allora 
	DECLARE @maxRientri INT 

	SELECT @maxRientri = ISNULL(g.[NRientri],0)
	FROM CasinoLayout.tbl_TorneiPokerGiornate g 
	WHERE g.PK_TPGiornataID = @FK_TPGiornataID
	--SELECT  @maxRientri

	SELECT @Count=ISNULL(COUNT(*),0)
	FROM Snoopy.tbl_PokerTorneoCashMov cm
	WHERE cm.FK_TPGiornataID = @FK_TPGiornataID 
	AND cm.MoveType = 0			--tipo BuyIn
	AND cm.FK_CustomerID = @FK_CustomerID 
	AND CancelID IS null
	--SELECT  @Count


	IF @Count IS NULL 
		SET @Count = 0 --primo buyin della giornata
	
	IF @Count < @maxRientri + 1
		--possiamo ancora rientrare o entriamo per la prima volta
		SET @Count = 1
	else
	--abbiamo gia raggiunto il massimo.
		SET @Count = 0 

	--SELECT  @Count



--SET @count = 1

RETURN @Count

END

GO
