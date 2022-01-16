SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [deprecated].[usp_GetChipMovement]
@gaming DATETIME
AS


select ForIncassoTag, Amount from deprecated.fn_GetChipMovement (@gaming)

GO
