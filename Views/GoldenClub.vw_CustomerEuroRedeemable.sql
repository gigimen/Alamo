SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [GoldenClub].[vw_CustomerEuroRedeemable]
WITH SCHEMABINDING
AS
SELECT 
	t.CustomerID,
	MIN(t.TransactionID) AS oldestTransID,
	COUNT(*) AS AcquistiDaRedemption,
	MIN(t.InsertTimestamp) AS Prima,
	MAX(t.InsertTimestamp) AS Ultima,
	ISNULL(SUM(CAST(t.ImportoEuroCents AS FLOAT) / 100),0) AS TotOrginalEuros ,
	ISNULL(SUM(CAST(t.LeftToBeRedeemedCents AS FLOAT) / 100),0) AS TotEuros ,
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.BirthDate,
	c.InsertDate AS CustInsertDate,
	g.GoldenClubCardID
FROM [GeneralPurpose].[ConfigParams] co, Accounting.tbl_EuroTransactions t
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = t.LifeCycleID
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = t.CustomerID 
INNER JOIN GoldenClub.tbl_Members g ON g.CustomerID = t.CustomerID 
WHERE
 l.GamingDate >= [GeneralPurpose].fn_GetGamingLocalDate2(
		GETUTCDATE(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GETUTCDATE(),GETDATE()),
		3 --SMT changes GamingDate at 7:00
		) - CAST(co.VarValue AS INT) + 1
AND t.CustomerID IS NOT NULL
AND t.CancelID IS NULL
--and t.LeftToBeRedeemed > 0 --still something redeemable
AND t.OpTypeID = 11 --count only acquisti
AND co.VarName = 'EuroGoldenValidityDays'
GROUP BY t.CustomerID,
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.BirthDate,
	c.InsertDate,
	g.GoldenClubCardID
GO
