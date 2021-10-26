SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [Managers].[msp_UpdateRegistrationTime] 
@regID int,
@timeLoc datetime
AS
if not @regID is null
begin
	begin transaction UpdateRegistrationTime
	declare @err int
	UPDATE Snoopy.tbl_Registrations
	   SET [TimeStampUTC] = GeneralPurpose.fn_UTCToLocal(0,@timeLoc)
		  ,[TimeStampLoc] = @timeLoc
	 WHERE RegID = @regid
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION UpdateRegistrationTime	return @ERR		end

	Commit transaction UpdateRegistrationTime


end



GO
