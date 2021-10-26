SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Accounting].[vw_LGTableState]
WITH SCHEMABINDING
AS
SELECT 
	inc.StockID,
	inc.Tag,
	inc.GamingDate,
	inc.LifeCycleID,
	inc.StateTime,
	GeneralPurpose.fn_UTCToLocal(1,inc.StateTime) as StateTimeLoc,
	inc.IncrResult,
	o.TableISOpen
from Accounting.vw_ARResultIncrements inc
inner join  Accounting.vw_LGTableOpenHours o on o.LifeCycleID = Inc.LifeCycleID and o.StateTime = Inc.StateTime
GO
