SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [Snoopy].[usp_GetTodaySesamControls]
@SiteID int
AS
 
declare @gaming datetime
set @gaming = GeneralPurpose.fn_GetGamingLocalDate2(getdate(),0,7) --use main cassa change of GamingDate

select 
[TimeStampLoc] as ora,
[searchString],
[HitsNumber]
from Snoopy.tbl_VetoControls
where [SiteID] = @SiteID and [GamingDate] = @gaming
order by [TimeStampUTC] desc
GO
