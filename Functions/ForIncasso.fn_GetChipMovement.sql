SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [ForIncasso].[fn_GetChipMovement]
(
    @gaming DATETIME
)
/*

select * from [Accounting].[fn_GetRifornimentiKiosk] ('4.16.2019')

*/
RETURNS @RifList TABLE (ForIncassoTag VARCHAR(32), Amount INT)
--WITH SCHEMABINDING
AS
BEGIN

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('4.4.2019' ,'OGGI')
 execute [ForIncasso].[usp_ChipMovement] '5.3.2019' ,'IERI'
 

DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

SET @gaming = '5.30.2019'
set 	@oggi = 'OGGI'


--*/

INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)

SELECT ForIncassoTag,Amount FROM [ForIncasso].[fn_GetChipMovementPartial] (
   DATEADD(DAY,-1,@gaming)
  ,'IERI')



INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)

SELECT ForIncassoTag,Amount FROM [ForIncasso].[fn_GetChipMovementPartial] (
   @gaming
  ,'OGGI')

RETURN

END
GO
