SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [GeneralPurpose].[usp_GetCurrentLocalGamingDate]
@StockTypeID as int
AS

	if (@StockTypeID is null) or (@StockTypeID not in (select StockTypeID from CasinoLayout.StockTypes))
	begin
		raiserror('Must specify a valid StockTypeID',16,-1)
		return (1)
	END
/*
declare
@StockTypeID as int

set  @StockTypeID = 5 

--*/
declare @gamingdate datetime

select @gamingdate =  GeneralPurpose.fn_GetGamingLocalDate2(
					GetUTCDate(),
					--pass current hour difference between local and utc 
					DATEDIFF (hh , GetUTCDate(),GetDate()),
					@StockTypeID
					)
--set @gamingdate = '12.19.2020'
select 'GamingDate' = @gamingdate

GO
