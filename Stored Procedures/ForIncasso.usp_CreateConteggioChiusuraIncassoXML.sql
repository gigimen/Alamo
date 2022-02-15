SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [ForIncasso].[usp_CreateConteggioChiusuraIncassoXML] 
@GamingDate			DATETIME,
@UserAccessID		INT,
@values				VARCHAR(MAX),
@SnapshotID			INT OUTPUT,
@SnapshotTimeLoc	DATETIME OUTPUT,
@SnapshotTimeUTC	DATETIME OUTPUT
AS

if @GamingDate is null 
begin
	raiserror('Invalid @GamingDate specified',16,1)
	RETURN 1
END

IF @values is NULL OR LEN(@values) = 0
begin
	raiserror('Must specify Chiusura values',16,1)
	RETURN 1
END

declare @LifeCycleID int,@ret int

select @LifeCycleID = LifeCycleID
from Accounting.tbl_LifeCycles 
where StockID = 47 and GamingDate = @GamingDate

IF @LifeCycleID IS NULL 
BEGIN
	raiserror('Incasso non è stato aperto per il gaming date specificato',16,1)
	return 1
END

IF NOT EXISTS (SELECT IntRate from
Accounting.tbl_CurrencyGamingdateRates  WHERE GamingDate = @GamingDate + 1 AND CurrencyID = 0)
BEGIN
	raiserror('No esiste il cambio euro per il gaming date specificato',16,1)
	return 1
END


--look for conteggio uscita
SELECT @SnapshotID = ConteggioID 
FROM [Accounting].[tbl_Conteggi]
WHERE GamingDate = @GamingDate AND SnapshotTypeID = 6  --conteggio uscita

IF @SnapshotID IS NULL 
BEGIN
	EXECUTE @ret = [Accounting].usp_CreateConteggioXML
		6,--@ssTypeID = 0,                        
	    @GamingDate,      
	    @UserAccessID,                                
	    @values  ,                               
	    @SnapshotID OUTPUT,       
	    @SnapshotTimeLoc OUTPUT, -- datetime
	    @SnapshotTimeUTC OUTPUT  -- datetime
	 

END
ELSE
BEGIN

	EXECUTE @ret = [Accounting].[usp_UpdateConteggioXML] 
	   @SnapshotID
	  ,@values
	  ,@UserAccessID

END

RETURN @ret
GO
