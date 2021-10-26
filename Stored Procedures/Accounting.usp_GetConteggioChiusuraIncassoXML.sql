SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [Accounting].[usp_GetConteggioChiusuraIncassoXML]
@SnapshotTypeID int, --should always be 6
@gamingdate datetime
AS
SELECT [DenoID]
      ,[Quantity] * [Denomination] as ValueSfr
FROM [Accounting].[vw_AllSnapshotDenominations]
where stockid = 47 and SnapshotTypeID = @SnapshotTypeID and Gamingdate = @gamingdate
GO
