SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_GetTotDiffCassa] 
@gaming datetime,
@DiffCassaTot float output
AS
declare @gamingRet 	datetime 
declare @LastGamingDate datetime 
declare @Chiusura 	float  	 
declare @apertura 	float  	 
declare @ConsegnaPerRipristino 	float  	 
declare @ripristino 	float  	 
declare @DiffCassa 	float 	
declare @cngnXripID	int	
set @DiffCassaTot = 0

declare @ret int
set @ret = CURSOR_STATUS ('global','trolley_cursor')
print 'CURSOR_STATUS returned ' + cast(@ret as varchar) 
if @ret > -3
begin
	print 'deallocting trolley_cursor'
	DEALLOCATE trolley_cursor
end
DECLARE trolley_cursor CURSOR
   FOR
--get all trolleys that have been closed that gaming date
	SELECT  LastChiusuraSS.LifeCycleID
	FROM    CasinoLayout.Stocks 
	--use inner join because we don't want ot see trolleys that has not been opened that day
	INNER JOIN Accounting.vw_AllLifeCycleNonCancelledSnapshots LastChiusuraSS
	ON LastChiusuraSS.StockID = CasinoLayout.Stocks.StockID 
	WHERE   LastChiusuraSS.GamingDate = @gaming
		AND LastChiusuraSS.SnapshotTypeID  = 3 --Chiusura
		AND (CasinoLayout.Stocks.StockTypeID IN
                    (SELECT     StockTypeID
                     FROM      CasinoLayout.StockTypes
                     WHERE      FDescription = 'Trolleys' 
		     OR FDescription = 'Main Trolleys')
		    )
	ORDER BY CasinoLayout.Stocks.StockID
OPEN trolley_cursor
DECLARE @LifeCycleID int
FETCH NEXT FROM trolley_cursor INTO @LifeCycleID
WHILE (@@FETCH_STATUS <> -1)
BEGIN
   print ''
   print ''--@LifeCycleID

   exec @ret = Accounting.usp_GetDifferenzaDiCassa
	@LifeCycleID,
	@gamingRet 	 out,
	@LastGamingDate  out,
	@Chiusura 	 out,
	@apertura 	 out,
	@ConsegnaPerRipristino 	 out,
	@cngnXripID	 out,
	@ripristino 	 out,
	@DiffCassa 	 out



--   if @ret <> 0
--	BREAK
--   print 'Diff Cassa : ' + convert(varchar(32),@DiffCassa)
   set @DiffCassaTot = @DiffCassaTot + @DiffCassa
  
   FETCH NEXT FROM trolley_cursor INTO @LifeCycleID
END
if CURSOR_STATUS ('local','trolley_cursor') > -3
	DEALLOCATE trolley_cursor

print 'Diff Cassa totale: ' + str(@DiffCassaTot,12,2)
GO
GRANT EXECUTE ON  [Accounting].[usp_GetTotDiffCassa] TO [SolaLetturaNoDanni]
GO
