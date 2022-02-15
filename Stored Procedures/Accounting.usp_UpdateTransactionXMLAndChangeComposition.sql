SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_UpdateTransactionXMLAndChangeComposition] 
@TransID		INT		,
@values			VARCHAR(MAX),
@UAID			INT	
AS


if ( @TransID is null)
begin
	raiserror('Cannot specify a null @TransID ',16,-1)
	RETURN (1)
END
/*
DECLARE @TransID		INT	,
@values			VARCHAR(MAX)	

SET @TransID = 476204



set @values = '<ROOT>
<DENO denoid="1" qty="0" exrate="1.58" CashInbound="1" />
<DENO denoid="2" qty="4" exrate="1.58" CashInbound="0" />
<DENO denoid="3" qty="123" exrate="1.58" CashInbound="1" />
</ROOT>'

--*/

DECLARE @RC INT,@StockID INT,@CompositionID INT, @chiusuraSSID INT,@Gamingdate datetime

SELECT @StockID = t.DestStockID,@Gamingdate = t.SourceGamingDate
FROM Accounting.vw_AllTransactions t
WHERE t.TransactionID = @TransID 
AND t.OpTypeID = 5 --must be a ripristino
AND t.DestStockTypeID IN (4,7) --must be a cassa or main cassa


IF @StockID IS null
BEGIN
	RAISERROR('Non è un ripristino per casse (%d)',16,1,@TransID)
	RETURN 1
END



--vai a vedere come ha chiuso il giorno prima la cassa
SELECT @CompositionID = s.StockCompositionID,
@chiusuraSSID = s.ChiusuraSnapshotID
FROM [Accounting].[vw_AllChiusuraConsegnaRipristino] s
WHERE s.StockID = @StockID
AND s.GamingDate = @Gamingdate

IF @CompositionID IS null
BEGIN
	RAISERROR('Non esiste la composizione della cassa',16,1)
	RETURN 1
END

IF @chiusuraSSID IS null
BEGIN
	RAISERROR('Non esiste la chiusura della cassa',16,1)
	RETURN 1
END


SELECT @StockID,@chiusuraSSID,@CompositionID




--prima di tutto modifica il ripristino
EXECUTE @RC = [Accounting].[usp_UpdateTransactionXML] 
	@TransID
	,@values
	,@UAID

IF @RC <>0
	RETURN @RC



--adesso puoi modificare la composizione



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ChangeComposition

BEGIN TRY  

	declare @XML xml = @values

	UPDATE [CasinoLayout].[StockComposition_Denominations]
	SET [InitialQty]		= a.NuovaComp
	FROM [CasinoLayout].[StockComposition_Denominations] s
	INNER JOIN 
	(
	select	ISNULL(n.DenoID,v.DenoID) AS DENOID,
			n.[Quantity] AS ripristino,
			v.[Quantity] AS chiusura,
			ISNULL(n.Quantity,0) + ISNULL(v.[Quantity],0) AS NuovaComp
	from 
	(
		SELECT 
			T.N.value('@denoid', 'int') AS DenoID,
			--T.N.value('@qty', 'int') AS [Quantity],
			cast(T.N.value('@qty', 'float') as Int) AS [Quantity],
			T.N.value('@exrate', 'float') AS [ExchangeRate],
			T.N.value('@CashInbound', 'bit') AS CashInbound
		from @XML.nodes('ROOT/DENO') as T(N)
	)n
	FULL OUTER JOIN 
	(
		SELECT 
			DenoID,
			[Quantity],
			[ExchangeRate]
		from Accounting.tbl_SnapshotValues t
		where t.LifeCycleSnapshotID = @chiusuraSSID 
	) v ON n.DenoID = v.DenoID
	) a ON a.DENOID = s.DenoID
	WHERE s.StockCompositionID = @CompositionID



	COMMIT TRANSACTION trn_ChangeComposition
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ChangeComposition	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
