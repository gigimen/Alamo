SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [ForIncasso].[usp_GetAperturaTesoro] 
@gaming			DATETIME
AS


if @gaming is null or @gaming = null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END




/*

DECLARE @gaming DATETIME

SET @gaming = '10.16.2019'

execute [ForIncasso].[usp_GetAperturaTesoro]  @gaming


--*/



declare @AperturaTesoro as table (ValueTypeName varchar(32), Total	int,maxtimeLoc	datetime)

insert into @AperturaTesoro execute [ForIncasso].[usp_GetAperturaTesoroEx] @gaming
select 'X_BAL_AP_OGGI_' + UPPER(ValueTypeName)  AS ForIncassoTag,
	Total AS Amount
from @AperturaTesoro
GO
