SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Snoopy].[vw_FluttuazioneDenaroTrovato]
WITH SCHEMABINDING
AS
select top 100 percent
	isnull(t.gamingdate,isnull(r.gamingdate,c.SourceGamingDate)) as gamingdate,
	isnull(t.TotTrovato,0) as DenaroTrovato,
	isnull(r.totrestituito,0) as DenaroRestituito,
	isnull(t.TotTrovato,0) - isnull(r.totrestituito,0) as Bilancio,
	cast(isnull(c.Quantity,0) as float)/100.0 as ChiusuraCassa
	from
(
SELECT Sum([Rap_ImportoCHF]) as totrestituito
      ,[Rap_Datarestituzione] as gamingdate
  FROM Snoopy.tbl_DenaroTrovato
  where Rap_Datarestituzione is not null and Rap_Datarestituzione >= '1.1.2012'
  group by Rap_Datarestituzione
) r
full outer join 
(
SELECT Sum([Rap_ImportoCHF]) as TotTrovato
      ,Rap_GamingDate  as gamingdate
  FROM Snoopy.tbl_DenaroTrovato
  where Rap_GamingDate is not null and Rap_GamingDate >= '1.1.2012'
  group by Rap_GamingDate
) t on r.gamingdate = t.gamingdate
full outer join
(
SELECT [SourceGamingDate]
      ,[Quantity]
  FROM Accounting.vw_AllTransactionDenominations
  where SourceStockID = 46 and optypeid = 6 and denoid = 105
  and SourceGamingDate >= '1.1.2012'
) c on r.gamingdate = c.SourceGamingDate or t.gamingdate = c.SourceGamingDate
order by  isnull(t.gamingdate,isnull(r.gamingdate,c.SourceGamingDate)) 












GO
