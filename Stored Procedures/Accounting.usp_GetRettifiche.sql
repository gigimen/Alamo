SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [Accounting].[usp_GetRettifiche]
@lfid INT,
@currencyID INT,
@countRettifiche INT OUTPUT,
@TotCents		INT OUTPUT
AS
/*

declare
@lfid INT,
@currencyID INT,
@countRettifiche INT ,
@TotCents		INT 

set @lfid =192467
set @currencyID = 4

--execute  Accounting.usp_GetRettifiche @lfid ,@currencyID ,@countRettifiche output ,@TotCents		output

--select @countRettifiche as 'countRettifiche',@TotCents		as 'TotCents' 


--*/
DECLARE @gamingdate DATETIME
SELECT @gamingdate = Gamingdate 
FROM Accounting.vw_AllStockLifeCycles 
WHERE  LifeCycleID = @lfid AND StockTypeID = 7 --only main cassa
IF @gamingdate IS NULL 
BEGIN
	RAISERROR('Invalid @lfid specified',16,1)
	RETURN 1
END

IF @currencyID IS NULL OR @currencyID NOT IN (0,4)
BEGIN
	RAISERROR('Invalid @currencyID specified',16,1)
	RETURN 1
END

SELECT @countRettifiche = ISNULL(COUNT(CASE WHEN @currencyID = 0 THEN [EURCents] ELSE [CHFCents] END ),0)
      ,@TotCents = ISNULL(SUM(CASE WHEN @currencyID = 0 THEN [EURCents] ELSE [CHFCents] END),0) 
FROM [Accounting].[tbl_Rettifiche]
WHERE [FK_LifeCycleID] = @lfid 
--select @countRettifiche as 'countRettifiche',@TotCents		as 'TotCents' 

SELECT ISNULL(COUNT(CASE WHEN @currencyID = 0 THEN [EURCents] ELSE [CHFCents] END ) ,0)
      ,ISNULL(SUM(CASE WHEN @currencyID = 0 THEN [EURCents] ELSE [CHFCents] END),0) 
FROM [Snoopy].[vw_AllRettificaRestituizioni]
WHERE RestGamingDate = @gamingdate

SELECT @countRettifiche += ISNULL(COUNT(CASE WHEN @currencyID = 0 THEN [EURCents] ELSE [CHFCents] END ) ,0)
      ,@TotCents -= ISNULL(SUM(CASE WHEN @currencyID = 0 THEN [EURCents] ELSE [CHFCents] END),0) 
FROM [Snoopy].[vw_AllRettificaRestituizioni]
WHERE RestGamingDate = @gamingdate
--select @countRettifiche as 'countRettifiche',@TotCents		as 'TotCents' 
GO
