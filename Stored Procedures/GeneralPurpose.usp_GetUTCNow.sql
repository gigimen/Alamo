SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [GeneralPurpose].[usp_GetUTCNow] AS
select 'Now' =  GetUTCDate()

GO
