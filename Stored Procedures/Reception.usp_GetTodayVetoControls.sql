SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE procedure [Reception].[usp_GetTodayVetoControls]
@siteID int
AS
 
declare @gaming datetime
set @gaming = GeneralPurpose.fn_GetGamingLocalDate2(getdate(),0,7) --use main cassa change of gamingdate

select 
[TimeStampLoc] as ora,
[searchString],
[HitsNumber]
from Reception.tbl_VetoControls
where [SiteId] = @siteID and [gamingDate] = @gaming
order by [TimeStampUTC] desc

GO
