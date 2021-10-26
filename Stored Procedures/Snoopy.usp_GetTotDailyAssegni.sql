SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Snoopy].[usp_GetTotDailyAssegni] 
@lfid int,
@allassegni bit,
@TotAssegniCHF float OUTPUT,
@CountAssegniCHF INT OUTPUT
AS

if not exists (select GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @lfid)
begin
	raiserror('Invalid LifeCycleID %d specified',16,1,@lfid)
	return (2)
END


/*
	if(allTrolleys)
		g_AlamoConn.Execute(
			&rs,
			"select sum(CHF) as TotAssegni,count(*) as CountAssegni from "VIEW_ALLASSEGNI
			" where GamingDate in ( select GamingDate from "TABLE_LIFECYCLES" where LifeCycleID = %d)"
			" and CentaxCode <> '"ASSEGNO_GARANZIA_NOGARANZIA"'"//	" and CentaxCode is not null"
			" and CentaxCode <> '"ASSEGNO_GARANZIA_NOGARANZIA_CENTAX"'"//	" and CentaxCode is not null"
			" and RedemCustTransID is null", //not redempted
			lfid
			);
	else
		g_AlamoConn.Execute(
			&rs,
			"select sum(CHF) as TotAssegni,count(*) as CountAssegni from "VIEW_ALLASSEGNI
			" where EmissLFID = %d"
			" and CentaxCode <> '"ASSEGNO_GARANZIA_NOGARANZIA"'"//	" and CentaxCode is not null"
			" and CentaxCode <> '"ASSEGNO_GARANZIA_NOGARANZIA_CENTAX"'"//	" and CentaxCode is not null"
			" and RedemCustTransID is null", //not redempted
			lfid
			);
*/
IF @allassegni = 1
begin
	SELECT @TotAssegniCHF = ISNULL(SUM(CHF),0),
			@CountAssegniCHF = ISNULL(COUNT(*),0)
	from [Snoopy].[vw_AllAssegni]
	where GamingDate in ( select GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @lfid )
	and CentaxCode <> 'NG'
	and CentaxCode <> 'NG-C'
	and RedemCustTransID is NULL

END
ELSE
begin
	SELECT @TotAssegniCHF = ISNULL(SUM(CHF),0),
			@CountAssegniCHF = ISNULL(COUNT(*),0)
	from [Snoopy].[vw_AllAssegni]
	where EmissLFID = @lfid
	and CentaxCode <> 'NG'
	and CentaxCode <> 'NG-C'
	and RedemCustTransID is NULL
end
GO
