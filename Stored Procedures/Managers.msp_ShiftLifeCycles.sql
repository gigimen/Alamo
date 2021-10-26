SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE  [Managers].[msp_ShiftLifeCycles]
@gaming DATETIME,
@days INT 
AS

--shift back one day all life cycles snapshots
UPDATE Accounting.tbl_Snapshots 
	SET Accounting.tbl_Snapshots.SnapshotTime = DATEADD(dd,@days,Accounting.tbl_Snapshots.SnapshotTime)
FROM Accounting.tbl_Snapshots
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleid = Accounting.tbl_Snapshots.LifeCycleid
WHERE l.gamingdate = @gaming

--shift back one day all life cycles progress
UPDATE Accounting.tbl_Progress 
	SET StateTime = DATEADD(dd,@days,Accounting.tbl_Progress.StateTime)
FROM Accounting.tbl_Progress
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleid = Accounting.tbl_Progress.LifeCycleid
WHERE l.gamingdate = @gaming

--shift back one day all life cycles transactions
UPDATE Accounting.tbl_Transactions 
	SET SourceTime = DATEADD(dd,@days,SourceTime)
FROM Accounting.tbl_Transactions
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleid = Accounting.tbl_Transactions.SourceLifeCycleid
WHERE l.gamingdate = @gaming

--shift back one day all exchane rates
UPDATE Accounting.tbl_Transactions 
	SET DestTime = DATEADD(dd,@days,DestTime)
FROM Accounting.tbl_Transactions
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleid = Accounting.tbl_Transactions.DestLifeCycleid
WHERE l.gamingdate = @gaming

UPDATE Snoopy.tbl_CustomerTransactions 
	SET CustomerTransactionTime = DATEADD(dd,@days,CustomerTransactionTime)
FROM Snoopy.tbl_CustomerTransactions
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleid = Snoopy.tbl_CustomerTransactions.SourceLifeCycleid
WHERE l.gamingdate = @gaming

UPDATE Accounting.tbl_CashlessTransactions 
	SET TransTime = DATEADD(dd,@days,TransTime)
FROM Accounting.tbl_CashlessTransactions
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleid = Accounting.tbl_CashlessTransactions.LifeCycleid
WHERE l.gamingdate = @gaming

UPDATE Accounting.tbl_CurrencyGamingdateRates 
	SET GamingDate = DATEADD(dd,@days,GamingDate)
WHERE Gamingdate = @gaming

--shift back one day all life cycles
UPDATE Accounting.tbl_LifeCycles 
	SET Accounting.tbl_LifeCycles.GamingDate = DATEADD(dd,@days,Accounting.tbl_LifeCycles.GamingDate)
WHERE gamingdate = @gaming

GO
