SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetDifferenzaDiCassaEx] 
@LifeCycleID 				INT
AS

declare
@ChiusuraSSID				INT		

select  
	@ChiusuraSSID = LifeCycleSnapshotID
	from Accounting.vw_AllSnapshotsEx 
	where LifeCycleID = @LifeCycleID 
	AND SnapshotTypeID = 3 --Chiusura
if @ChiusuraSSID is null
begin
	raiserror('Error getting Chiusura snapshot for LifeCycleID %d',16,-1,@LifeCycleID)
	RETURN (1)
END


DECLARE @ret INT

EXECUTE @ret = [Accounting].[usp_GetSnapshotDifferenzaDiCassa] @ChiusuraSSID

RETURN @ret
GO
