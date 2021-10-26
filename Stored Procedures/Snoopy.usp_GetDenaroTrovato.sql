SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Snoopy].[usp_GetDenaroTrovato] 
@LifeCycleID int,
@totDenaro float output,
@countDenaro int output
AS

if @LifeCycleID is null and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	return 1
end

declare @GamingDate datetime
select @GamingDate = GamingDate from Accounting.tbl_LifeCycles
where LifeCycleID = @LifeCycleID


SELECT 
@totDenaro =
isnull(
	sum(
		(
		case 
		when Rap_Datarestituzione = @GamingDate AND Rap_GamingDate = @GamingDate THEN 0
		when Rap_Datarestituzione = @GamingDate then -1
		else 1
		end) * Rap_ImportoCHF
		),
	0),
@countDenaro =
isnull(	
		count(*)
		,0
	   )
FROM Snoopy.tbl_DenaroTrovato
where Rap_GamingDate = @GamingDate or Rap_Datarestituzione = @GamingDate


GO
