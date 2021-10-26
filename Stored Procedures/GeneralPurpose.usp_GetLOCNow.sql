SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [GeneralPurpose].[usp_GetLOCNow] 
AS
select 'Now' =  GetDate()

GO
