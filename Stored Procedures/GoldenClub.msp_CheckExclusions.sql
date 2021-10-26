SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Stored Procedure

CREATE PROCEDURE [GoldenClub].[msp_CheckExclusions]
AS
BEGIN

/*

execute [GoldenClub].[msp_CheckExclusions]

*/

declare @body varchar(MAX),
@sub VARCHAR(256),
@lastname varchar(256),
@firstname  varchar(256),
@birthday DATETIME,
@BarrierStart DATETIME,
@CasinoName varchar(256),
@CustomerID INT,
@GoldenClubCardID INT,
@fraCount INT,
@SiteName varchar(64),
@TimeStampLoc DATETIME,
@STOP BIT,
@rc	INT




--print @SQL
--EXEC sp_executesql @SQL  




set @body = 'Cancellati i seguenti Golden perchè esclusi in Veto:

'

SET @fraCount = 0
declare exclu_cursor cursor for
	SELECT 
		[lastname]
      ,[firstname]
      ,[birthday]
      , BarrierStart
      , CasinoName
      ,[alamoCustomerID]
      ,[GoldenClubCardID]
  FROM [Snoopy].[vw_VetoPlusGoldenClub]
  WHERE Barrier in(2,8,10) 
  AND CustomerID IS NOT NULL -- golden club match
  AND GoldenClubCardID IS NOT NULL  --the customer has goldenclub card associated to him
  AND Canceldate IS NULL

Open exclu_cursor

Fetch Next from exclu_cursor into 
@lastname ,
@firstname ,
@birthday ,
@BarrierStart ,
@CasinoName ,
@CustomerID ,
@GoldenClubCardID 

SET @STOP = 0
SET @rc = 0 
While @@FETCH_STATUS = 0 AND @STOP = 0 AND @rc = 0
Begin
	set @body = @body + '
'+@lastname+' '+@firstname + ' ' + CONVERT(varchar(16),@birthday,105) + ' |           Escluso dal :' + CONVERT(varchar(16),@BarrierStart,105) + ' da '+@CasinoName+'   CardID:' + cast(@GoldenClubCardID as varchar(10));

begin try
	--PRINT  @body
	EXECUTE @rc = [GoldenClub].[msp_RemoveFromGoldenClub]
		@CustomerID, -- int
	    207023,--@UserAccessID = 1, -- int
	    @TimeStampLoc					OUTPUT,
	    @SiteName						OUTPUT
		
	SET @fraCount = @fraCount + 1		

end try
begin catch

	set @BODY =@BODY +'
ERROR: ' + ERROR_MESSAGE()
	SET @STOP = 1
end catch	    

	Fetch Next from exclu_cursor into 
	@lastname ,
	@firstname ,
	@birthday ,
	@BarrierStart ,
	@CasinoName ,
	@CustomerID ,
	@GoldenClubCardID  
End

close exclu_cursor
deallocate exclu_cursor


IF @fraCount > 0
begin
	SET @sub = 'Cancellati ' + CAST(@fraCount as varchar(16)) + ' clienti dal golden perchè esclusi da Sesam'

	exec msdb.dbo.[sp_send_dbmail]
		@recipients                 = 'ReportAlamo@cmendrisio.office.ch', 
		@subject                    = @sub,
		@body                       = @body
END
ELSE IF @STOP = 1
begin
	exec msdb.dbo.[sp_send_dbmail]
		@recipients                 = 'ReportAlamo@cmendrisio.office.ch', 
		@subject                    = 'ERROR Canceling ADMIRAL MEMBERS',
		@body                       = @body

END
ELSE 
	PRINT 'none found!!'
--PRINT @body
END

GO
