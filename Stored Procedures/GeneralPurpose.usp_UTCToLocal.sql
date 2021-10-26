SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [GeneralPurpose].[usp_UTCToLocal] 
@UtcTime datetime,
@utctolocal int,
@LocTime datetime output
AS
EXECUTE @LocTime = GeneralPurpose.fn_UTCToLocal @utctolocal,@UtcTime

GO
