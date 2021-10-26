SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Snoopy].[usp_GetTotDailyAssegniEx] 
@lfid INT,
@allassegni BIT,
@TotAssegniEUR FLOAT OUTPUT,
@TotCommissioni FLOAT OUTPUT,
@CountAssegni INT OUTPUT
AS

IF NOT EXISTS (SELECT GamingDate FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @lfid)
BEGIN
	raiserror('Invalid LifeCycleID %d specified',16,1,@lfid)
	RETURN (2)
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
BEGIN
	SELECT @TotCommissioni = ISNULL(SUM(CommissioneEuro),0),
			@TotAssegniEUR =ISNULL(SUM(Importo),0),
			@CountAssegni = ISNULL(COUNT(DISTINCT AssegnoID),0)
	FROM [Snoopy].[vw_AllAssegniEx]
	WHERE GamingDate IN ( SELECT GamingDate FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @lfid )
	AND CentaxCode <> 'NG'
	AND CentaxCode <> 'NG-C'
	AND RedemCustTransID IS NULL

END
ELSE
BEGIN
	SELECT @TotCommissioni = ISNULL(SUM(CommissioneEuro),0),
			@TotAssegniEUR =ISNULL(SUM(Importo),0),
			@CountAssegni = ISNULL(COUNT(DISTINCT AssegnoID),0)
	FROM [Snoopy].[vw_AllAssegniEx]
	WHERE EmissLFID = @lfid
	AND CentaxCode <> 'NG'
	AND CentaxCode <> 'NG-C'
	AND RedemCustTransID IS NULL
END
GO
