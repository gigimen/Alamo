SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE procedure [GeneralPurpose].[usp_GetNow] 
@bUTC int,
@now datetime output
AS

if @bUTC = 1
	select @now =  GetUTCDate()
else
	select @now =  GetDate()
GO
