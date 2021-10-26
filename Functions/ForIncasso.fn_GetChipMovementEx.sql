SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [ForIncasso].[fn_GetChipMovementEx]
(
    @gaming DATETIME,@includeLucky BIT = 0
)
/*

select * from [ForIncasso].[fn_GetChipMovementEx] ('9.8.2020')

*/
RETURNS @RifList TABLE (ForIncassoTag VARCHAR(32), Amount INT)
--WITH SCHEMABINDING
AS
BEGIN

/*
select * from  [ForIncasso].[fn_GetChipMovement] ('9.8.2020' ,'OGGI')
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

SELECT ForIncassoTag,Amount FROM [ForIncasso].[fn_GetChipMovementPartialEx] (
   DATEADD(DAY,-1,@gaming)
  ,'IERI'
  ,@includeLucky)



INSERT INTO @RifList
(
    ForIncassoTag,
    Amount
)

SELECT ForIncassoTag,Amount FROM [ForIncasso].[fn_GetChipMovementPartialEx] (
   @gaming
  ,'OGGI'
  ,@includeLucky)


RETURN

END
GO
