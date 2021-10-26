SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_GetChiusureCasse]
@gaming  datetime,
@EuroRate float output,
@totStock float output
AS
/*
declare
@gaming  datetime,
@EuroRate float ,
@totStock float 

set @gaming = '7.20.2017'

--*/

declare @xb table 
(
OpName varchar(256),
DenoID int,
ValueTypeID int,
ValueTypeName varchar(128),
DenoName varchar(64),
Denomination float,
ExchangeRate float,
Qty			int
)

insert @xb
EXEC	[Accounting].[usp_GetXBalanceDenominations]
		@gaming,
		1,--@trolleys = 1,
		1,--@Chiusura = 1,
		@EuroRate OUTPUT,
		@totStock OUTPUT

--select * from @xb order by ValueTypeID,DenoID

select 
b.indx,
b.CHF
from
(
	select 
	a.indx,
	case when indx in(15,23,24) then -CHF
	else a.CHF
	end as CHF
	from
	(
		select [Accounting].[fn_YiuliaIndex] (ValueTypeID,DenoID) as indx,
		--ValueTypeName,DenoName,
		sum(ExchangeRate*Denomination*Qty) As CHF 
		from @xb
		where [Accounting].[fn_YiuliaIndex] (ValueTypeID,DenoID) is not null
		group by [Accounting].[fn_YiuliaIndex] (ValueTypeID,DenoID)
	)a

	union all

	select 
	14 as indx,
	Sum(Round([DiffCassa],2)) AS d
	--Sum(Round([DiffCassa],4))AS d
	FROM Accounting.vw_AllStockDiffCassa d 
	where d.GamingDate = @gaming
)b
order by b.indx
GO
