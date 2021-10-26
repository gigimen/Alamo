SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
	For maintenence purpose only
	not to be used by any other user rather than administrator!!!!
*/
CREATE PROCEDURE  [Managers].[msp_EmptyLifeCycles]
AS
	delete Accounting.tbl_Transaction_Confirmations
	delete Accounting.tbl_TransactionValues
	delete Accounting.tbl_Transactions
	delete Accounting.tbl_Snapshot_Confirmations
	delete Accounting.tbl_Progress
	delete Accounting.tbl_SnapshotValues
	delete Accounting.tbl_Snapshots
	delete FloorActivity.tbl_Cancellations
	delete Accounting.tbl_LifeCycles
	delete FloorActivity.tbl_UserAccesses

GO
