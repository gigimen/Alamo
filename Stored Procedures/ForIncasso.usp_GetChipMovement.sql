SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [ForIncasso].[usp_GetChipMovement]
@gaming DATETIME
AS


select ForIncassoTag, Amount from [ForIncasso].[fn_GetChipMovement] (@gaming)

GO
