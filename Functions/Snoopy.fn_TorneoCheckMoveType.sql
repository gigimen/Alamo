SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Snoopy].[fn_TorneoCheckMoveType](@movetype INT,@FK_TPGiornataID INT)

RETURNS INT

AS

BEGIN

DECLARE @Count INT

--Movetype is 0= BuyIn,1=Rotto,2=Vincita

IF @movetype = 0 --buyin
BEGIN
--make sure we don't have rotto or vincite
/*
Declare @Count int,@FK_TPGiornataID INT,@FK_CustomerID INT
	set @FK_CustomerID=56485
	set @FK_TPGiornataID=5

--*/	
	SELECT @Count=ISNULL(COUNT(*),0) 
	FROM Snoopy.tbl_PokerTorneoCashMov cm
	WHERE cm.FK_TPGiornataID = @FK_TPGiornataID AND MoveType IN (1,2) AND CancelID IS null
	
	--SELECT @Count

END
ELSE IF @movetype = 1 --rotto
BEGIN
--rotto must be unique
	SELECT @Count=COUNT(*) 
	FROM Snoopy.tbl_PokerTorneoCashMov cm
	WHERE cm.FK_TPGiornataID = @FK_TPGiornataID AND MoveType = @movetype AND CancelID IS null

	IF @Count IS NULL 
		SET @Count=0
END
ELSE IF @movetype = 2 --vincita
begin
--we cannot have rotti or buyin
	SELECT @Count=ISNULL(COUNT(*),0) 
	FROM Snoopy.tbl_PokerTorneoCashMov cm
	WHERE cm.FK_TPGiornataID = @FK_TPGiornataID AND MoveType IN(0,1) AND CancelID IS null
 
END

--SET @count = 0
RETURN @Count

END



GO
