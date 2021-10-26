SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetTableLastResult] 
	@lfid int
	,@ultimorestime datetime output
	,@penultimoRestime datetime output
	,@ultimores int output
	,@penultimores int output
	,@incremento int output
AS
 ---



set @ultimorestime		= null
set @penultimoRestime	= null
set @ultimores			= null
set @penultimores		= null
set @incremento			= null

select @ultimorestime = max([StateTime]) from Accounting.tbl_Progress p where p.LifeCycleID = @lfid and DenoID = 23
if @ultimorestime is not null
begin
	--store last resut
	select @ultimores = Quantity
	from Accounting.tbl_Progress p  where p.LifeCycleID = @lfid and p.DenoID = 23 and p.StateTime = @ultimorestime

	--look for previus result
	select @penultimoRestime = max([StateTime]) from Accounting.tbl_Progress p where p.LifeCycleID = @lfid and DenoID = 23 and StateTime < @ultimorestime
	
	if @penultimoRestime is not null
		select @penultimores=Quantity from Accounting.tbl_Progress p where p.LifeCycleID = @lfid and DenoID = 23 and StateTime = @penultimoRestime

	set @incremento = @ultimores - isnull(@penultimores,0)


	--ritorna il tempo in local
	set @ultimorestime = GeneralPurpose.fn_UTCToLocal(1,@ultimorestime)

end
GO
