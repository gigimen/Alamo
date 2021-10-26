SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Accounting].[usp_UpdateLifeCycleCloseXML]
@LFID			INT,
@values			VARCHAR(max),
@UAID			INT	
AS
DECLARE @LFSSID INT,@ret INT
select @LFSSID = LifeCycleSnapshotID from Accounting.tbl_Snapshots where LifeCycleID = @LFID AND SnapshotTypeID = 3 
IF @LFSSID IS null
BEGIN
	RAISERROR('Unexisting CHIUSURA Snapshot for LifeCycle (%d)',16,1,@LFID)
	RETURN 1
END

EXECUTE @ret = Accounting.usp_UpdateSnapshotXML 
	@LFSSID, -- int
    @values, -- varchar(max)
    @UAID -- int

RETURN @ret
GO
