SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Accounting].[usp_CheckDropConsistency]
(
	@currDrop	INT,
	@tOraUTC	DATETIME,
	@lfid		INT,
	@bOK		INT output
)
AS
if @tOraUTC is null
	set @tOraUTC = GETUTCDATE()
set @bOK = 1
if exists( select LifeCycleID from Accounting.tbl_Progress 
			where LifeCycleID = @lfid
			and DenoID = 11 --Denomination for soft count drop
			and (
				( Quantity > @currDrop and StateTime < @tOraUTC) or
				( Quantity < @currDrop and StateTime > @tOraUTC)
			    )
			) 
			set @bOK = 0
GO
