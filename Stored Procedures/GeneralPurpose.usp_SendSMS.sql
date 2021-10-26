SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [GeneralPurpose].[usp_SendSMS] 
@recipeints nvarchar(max),
@sms nvarchar(1024),
@o nvarchar(max) output
as
	DECLARE @RC int


	EXECUTE @RC = [SQLWebAPI].[usp_SendSMS] 
	   @recipeints
	  ,@sms
	  ,@o OUTPUT

RETURN @RC

GO
