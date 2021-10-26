SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [ForIncasso].[usp_GetChipMovementEx]
@gaming DATETIME
AS

/*
declare @gaming DATETIME

set @gaming = '8.20.2021'
select ForIncassoTag, Amount from [ForIncasso].[fn_GetChipMovementEx] (@gaming,1)

--*/
--dal 23.8.2021 includi ANCHE LE LUCKY CHIPS
select ForIncassoTag, Amount from [ForIncasso].[fn_GetChipMovementEx] (@gaming,1)--default)

GO
