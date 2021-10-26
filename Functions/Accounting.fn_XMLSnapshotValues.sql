SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Accounting].[fn_XMLSnapshotValues](
@SnapshotID	int
)  
RETURNS varchar(max) 
AS  
BEGIN 

/*

declare @SnapshotID	int
set @SnapshotID=388942

		SELECT DenoID,Quantity,ExchangeRate FROM Accounting.vw_AllSnapshotDenominations WHERE LifeCycleSnapshotID = @SnapshotID

--*/


/* esempio di tipico xml delle snapshot
set @values = '<ROOT>
<DENO denoid="1" qty="0" exrate="1.58"/>
<DENO denoid="2" qty="4" exrate="1.58"/>
<DENO denoid="3" qty="123" exrate="1.58"/>
</ROOT>'
*/


		declare @conXML as varchar(max),@DenoID int,@con int,@exrate  varchar(8)
		
		set @conXML = '<ROOT>'

		declare consegna_cursor cursor for
		SELECT DenoID,Quantity,ExchangeRate FROM Accounting.vw_AllSnapshotDenominations WHERE LifeCycleSnapshotID = @SnapshotID

		Open consegna_cursor

		Fetch Next from consegna_cursor into @DenoID,@con,@exrate
		While @@FETCH_STATUS = 0
		Begin

			if @con > 0
				set @conXML += '
		<DENO denoid="' + cast(@DenoID as varchar(16)) + '" qty="' + cast(@con as varchar(16))  + '" exrate="' + @exrate +'" />'
			Fetch Next from consegna_cursor into @DenoID,@con,@exrate
		End

		close consegna_cursor
		deallocate consegna_cursor

		set @conXML += '
</ROOT>'


/*
PRINT @conXML

declare @XML xml = @conXML

SELECT 
	T.N.value('@denoid', 'int') AS DenoID,
	cast(T.N.value('@qty', 'float') as int) AS [Quantity],
	T.N.value('@exrate', 'float') AS [ExchangeRate]
from @XML.nodes('ROOT/DENO') as T(N)


*/

RETURN @conXML
END
GO
