SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [ForIncasso].[usp_CreateConteggioChiusuraIncassoXML] 
@GamingDate			DATETIME,
@UserAccessID		INT,
@values				VARCHAR(MAX),
@SnapshotID			INT OUTPUT,
@SnapshotTimeLoc	DATETIME OUTPUT,
@SnapshotTimeUTC	DATETIME OUTPUT
AS

if @GamingDate is null 
begin
	raiserror('Invalid @GamingDate specified',16,1)
	RETURN 1
END

IF @values is NULL OR LEN(@values) = 0
begin
	raiserror('Must specify Chiusura values',16,1)
	RETURN 1
END

declare @LifeCycleID int,@ret int

select @LifeCycleID = LifeCycleID
from Accounting.tbl_LifeCycles 
where StockID = 47 and GamingDate = @GamingDate

IF @LifeCycleID IS NULL 
BEGIN
	raiserror('Incasso non è stato aperto per il gaming date specificato',16,1)
	return 1
END

IF NOT EXISTS (SELECT IntRate from
Accounting.tbl_CurrencyGamingdateRates  WHERE GamingDate = @GamingDate + 1 AND CurrencyID = 0)
BEGIN
	raiserror('No esiste il cambio euro per il gaming date specificato',16,1)
	return 1
END
/*
declare @LifeCycleID int
set @LifeCycleID = 160363

DECLARE @gamingdate DATETIME
SET @gamingdate = '4.26.2020'

declare @values as varchar(max)
   set @values = '<ROOT>'
   set @values = @values + '<DENO denoid ="161" qty="1" />'
   set @values = @values + '<DENO denoid ="191" qty="2" />'
   set @values = @values + '<DENO denoid ="192" qty="3" />'
   set @values = @values + '<DENO denoid ="193" qty="4" />'
   set @values = @values + '<DENO denoid ="194" qty="5" />'
   set @values = @values + '<DENO denoid ="138" stockid="47" exrate="1.0794" qty="15000000" />'
   set @values = @values + '</ROOT>'

declare @XML xml = @values

		SELECT 
		CASE 
		--kiosk euro1 e euro2
			WHEN T.N.value('@denoid', 'int') IN (193,194) THEN 171 --monete diversi euro
		--kiosk chf1 e chf2, tesoro gastro e tronc gastro
			WHEN T.N.value('@denoid', 'int') IN (191,192,161,111111) THEN 48 --monete diverse chf
			ELSE T.N.value('@denoid', 'int') 
		END AS DenoID,
		CASE 
			--tesoro gastro 
			WHEN T.N.value('@denoid', 'int') = 161 THEN 85
			--kiosk chf1
			WHEN T.N.value('@denoid', 'int') = 191 THEN 75
			--kiosk chf2
			WHEN T.N.value('@denoid', 'int') = 192 THEN 79
			--kiosk eur1
			WHEN T.N.value('@denoid', 'int') = 193 THEN 80
			--kiosk eur2
			WHEN T.N.value('@denoid', 'int') = 194 THEN 81
			--tronc gastro
			WHEN T.N.value('@denoid', 'int') = 111111 THEN 83

			ELSE T.N.value('@stockid', 'int')
		END AS StockID,
			T.N.value('@qty', 'int')	as QTY,
			CASE 
			WHEN T.N.value('@exrate', 'float') is not null then T.N.value('@exrate', 'float')
			WHEN d.CurrencyID = 0 THEN cur.IntRate ELSE 1 END 
			AS ExchangeRate
			--,s.ExchangeRate
			--,s.GamingDate,s.DenoID,s.ValueTypeName,s.DenoName
		from @XML.nodes('ROOT/DENO') as T(N)
		INNER JOIN CasinoLayout.vw_AllDenominations d ON d.DenoID = T.N.value('@denoid', 'int')
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates cur ON cur.GamingDate = @GamingDate + 1 AND cur.CurrencyID = d.CurrencyID

--*/
/*TRASFORMA LO SNAPSHOT conteggio uscita in un conteggio di tipo conteggio uscita per quel giorno*/
DECLARE 
	@DenoID int,
	@StockID int,
	@Qty int,
	@Exrate	FLOAT,
	@values2 VARCHAR(MAX)

declare @XML xml = @values


	declare exclu_cursor cursor for
		SELECT 
		CASE 
		--kiosk euro1 e euro2
			WHEN T.N.value('@denoid', 'int') IN (193,194) THEN 171 --monete diversi euro
		--kiosk chf1 e chf2, tesoro gastro e tronc gastro
			WHEN T.N.value('@denoid', 'int') IN (191,192,161,111111) THEN 48 --monete diverse chf
			ELSE T.N.value('@denoid', 'int') 
		END AS DenoID,
		CASE 
			--tesoro gastro 
			WHEN T.N.value('@denoid', 'int') = 161 THEN 85
			--kiosk chf1
			WHEN T.N.value('@denoid', 'int') = 191 THEN 75
			--kiosk chf2
			WHEN T.N.value('@denoid', 'int') = 192 THEN 79
			--kiosk eur1
			WHEN T.N.value('@denoid', 'int') = 193 THEN 80
			--kiosk eur2
			WHEN T.N.value('@denoid', 'int') = 194 THEN 81
			--tronc gastro
			WHEN T.N.value('@denoid', 'int') = 111111 THEN 83

			ELSE T.N.value('@stockid', 'int')
		END AS StockID,
			T.N.value('@qty', 'int')	as QTY,
			CASE 
			WHEN T.N.value('@exrate', 'float') is not null then T.N.value('@exrate', 'float')
			WHEN d.CurrencyID = 0 THEN cur.IntRate ELSE 1 END 
			AS ExchangeRate
			--,s.ExchangeRate
			--,s.GamingDate,s.DenoID,s.ValueTypeName,s.DenoName
		from @XML.nodes('ROOT/DENO') as T(N)
		INNER JOIN CasinoLayout.vw_AllDenominations d ON d.DenoID = T.N.value('@denoid', 'int')
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates cur ON cur.GamingDate = @GamingDate + 1 AND cur.CurrencyID = d.CurrencyID


	Open exclu_cursor
	Fetch Next from exclu_cursor into @DenoID ,@StockID ,@Qty ,@ExRate 
   set @values2 = '<ROOT>'

	While @@FETCH_STATUS = 0  
	BEGIN
	--<DENO denoid="153" stockid="5" exrate="1.000000" qty="1" />'
	   set @values2 = @values2 
	   + '<DENO denoid ="' + CAST(@DenoID AS varchar(16)) 
	   + '" stockid ="' + CAST(@StockID AS varchar(16)) 
	   + '" exrate ="' + CAST(@Exrate AS varchar(16)) 
	   + '" qty ="' + CAST(@Qty AS varchar(16)) 
	   + '" />'
		FETCH Next from exclu_cursor into @DenoID ,@StockID ,@Qty ,@ExRate 
	END

	close exclu_cursor
	deallocate exclu_cursor

	set @values2 = @values2 + '</ROOT>'

       PRINT @values2
/*
*/

--look for conteggio uscita
SELECT @SnapshotID = ConteggioID 
FROM [Accounting].[tbl_Conteggi]
WHERE GamingDate = @GamingDate AND SnapshotTypeID = 6  --conteggio uscita

IF @SnapshotID IS NULL 
BEGIN
	EXECUTE @ret = [Accounting].usp_CreateConteggioXML
		6,--@ssTypeID = 0,                        
	    @GamingDate,      
	    @UserAccessID,                                
	    @values2  ,                               
	    @SnapshotID OUTPUT,       
	    @SnapshotTimeLoc OUTPUT, -- datetime
	    @SnapshotTimeUTC OUTPUT  -- datetime
	 

END
ELSE
BEGIN

	EXECUTE @ret = [Accounting].[usp_UpdateConteggioXML] 
	   @SnapshotID
	  ,@values2
	  ,@UserAccessID

END

RETURN @ret
GO
