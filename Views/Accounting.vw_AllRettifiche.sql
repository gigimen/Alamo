SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllRettifiche]
--WITH SCHEMABINDING
AS
/*

select * from [Accounting].[vw_AllRettifiche] order by LifeCycleID desc

SELECT [Cosa]      ,[Cassa]      ,[GamingDate]      ,[LifeCycleID]      ,[EURCents]      ,[CHFCents]      ,[Nota]  
FROM [Accounting].[vw_AllRettifiche]	
WHERE (RettGamingDate = convert(datetime, '9-3-2021', 105)) AND [CHFCents] is not null
*/
SELECT 'Rettifica ' + cc.FName COLLATE Latin1_General_CI_AS AS Cosa ,
cc.Tag AS Cassa,
cc.GamingDate,
rett.FK_LifeCycleID AS LifeCycleID,
lf.GamingDate AS RettGamingDate,
-rett.EURCents AS EURCents, --la regisrtazione va in positivo se trovo i soldi 
-rett.CHFCents	AS CHFCents,
rett.Nota COLLATE Latin1_General_CI_AS AS Nota
FROM [Accounting].[tbl_Rettifiche] rett 
INNER JOIN [Accounting].[vw_AllSnapshotsEx] cc ON rett.FK_LifeCycleSnapshotID = cc.LifeCycleSnapshotID
INNER JOIN Accounting.tbl_LifeCycles LF ON LF.LifeCycleID = RETT.FK_LifeCycleID
UNION ALL 
SELECT 
CASE WHEN ISNULL(rs.EURCents,0) + ISNULL(rs.CHFCEnts,0)  > 0 THEN 'Restituzione ' ELSE 'Riscossione ' END + ' diff. cassa ' + LastName,
rs.Tag,
rs.GamingDate,
lf.LifeCycleID,
rs.RestGamingDate AS RettGamingDate,
rs.EURCents,
rs.CHFCents,
rs.Descrizione
FROM [Snoopy].[vw_AllRettificaRestituizioni] rs
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.GamingDate = rs.RestGamingDate AND lf.StockID = 46

GO
