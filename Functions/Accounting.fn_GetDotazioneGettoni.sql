SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Accounting].[fn_GetDotazioneGettoni]
(
      @Gamingdate DATETIME
)

RETURNS @r TABLE (
	Denomination		float,
	DenoID				INT, 
	tag					VARCHAR(32),
	Quantity			INT,
	Value				INT
	)
BEGIN
/*

select * from [Accounting].[fn_GetDotazioneGettoni] ('4.15.2019')
select * from [Accounting].[fn_GetDotazioneGettoni] ('4.15.2004')
*/
/*


declare @gamingdate datetime
set @gamingdate = '5.1.2019'

declare @r TABLE (
	Denomination		float,
	DenoID				INT, 
	Quantity			INT,
	Value				INT
	)
--*/




INSERT INTO @r

SELECT 
	a.Denomination,
	a.DenoID, 
	'CHIPMOV_DOT_' + CAST(a.DenoID AS VARCHAR(16)),
	a.Quantity			,
	a.Value				
FROM
(
SELECT  Denomination
		,CASE 
		WHEN DenoID IN( 1,128)	then   1
		WHEN DenoID IN( 2,129)	then   2
		WHEN DenoID IN( 3,130)	then   3
		WHEN DenoID IN( 4,131)	then   4
		WHEN DenoID IN( 5,132)	then   5
		WHEN DenoID IN( 6,133)	then   6
		WHEN DenoID IN( 7,134)	then   7
		WHEN DenoID IN( 8,135)	then   8
		WHEN DenoID IN( 9,136)	then   9
		ELSE DenoID
		END AS DenoID
--		,SUM(Quantity) AS Quantity
--      ,SUM(Quantity * [Denomination]) AS Value
--FROM [Accounting].[vw_AllConteggiDenominations]
--WHERE [SnapshotTypeID] = 17 AND gamingdate <= @Gamingdate
		,SUM((Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) ) AS Quantity
		,SUM((Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) * [Denomination]) AS Value
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
	AND SourceGamingDate <= @Gamingdate --somma tutte le variazioni di dotazione antecedenti 


GROUP BY Denomination,
CASE 
		WHEN DenoID IN( 1,128)	then   1
		WHEN DenoID IN( 2,129)	then   2
		WHEN DenoID IN( 3,130)	then   3
		WHEN DenoID IN( 4,131)	then   4
		WHEN DenoID IN( 5,132)	then   5
		WHEN DenoID IN( 6,133)	then   6
		WHEN DenoID IN( 7,134)	then   7
		WHEN DenoID IN( 8,135)	then   8
		WHEN DenoID IN( 9,136)	then   9
		ELSE DenoID
		END

) a
ORDER BY a.DenoID ASC
--select * from @r

      RETURN 
END
GO
