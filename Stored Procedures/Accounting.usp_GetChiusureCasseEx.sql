SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_GetChiusureCasseEx]
@gaming  datetime
AS
/*


declare
@gaming  datetime

set @gaming = '2.28.2018'

--*/
declare

@EuroRate float ,
@totStock float 

declare @xb table 
(
OpName varchar(256),
DenoID int,
ValueTypeID int,
ValueTypeName varchar(128),
DenoName varchar(64),
Denomination float,
IsFisical	BIT,
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
b.nome,
b.CHF,
b.Qty,
b.ExchangeRate
from
(
select a.nome,
	case when nome in('CASSE_DENARO_TROVATO','CASSE_UTILE_VENDITAEURO','CASSE_RETT_DIFF','CASSE_UTILE_COMMISSIONI')
		then -a.CHF
		else
		a.CHF
	end as CHF,
	a.Qty,
	a.ExchangeRate
	from
	(
		select [Accounting].[fn_Formulario_NAME] (ValueTypeID,DenoID) as nome,
		--ValueTypeName,DenoName,
		sum(ExchangeRate*Denomination*Qty) As CHF ,
		sum(Denomination*Qty) As Qty ,
		ExchangeRate
		from @xb
		where [Accounting].[fn_Formulario_NAME] (ValueTypeID,DenoID) is not null
		group by [Accounting].[fn_Formulario_NAME] (ValueTypeID,DenoID),ExchangeRate
	) a

	--add assegni in euro
	union all
		select 'CASSE_ASSEGNI_EUR',
		sum([Importo]) As CHF ,
		sum([CHF]) as Qty,
		[ExchangeRate]
		FROM [Snoopy].[vw_AllAssegni]
		where RedemCustTransID is null --not reddemed
		AND CentaxCode is not NULL --garantito
		AND CentaxCode <> 'ng-c'
		AND CentaxCode <> 'ng'	
		AND GamingDate = @gaming
		group by [ExchangeRate]

	union all
	--add CC in euro

		select 'CASSE_CC_ADUNO_EUR',
		sum([EuroAtTerminal]) As CHF ,
		sum([EuroAtTerminal]) as Qty,
		[ExchangeRate]
		FROM [Accounting].[vw_AllCartediCredito]
		where CustomerID <> 1 and GamingDate = @gaming
		group by [ExchangeRate]

	union all

	select 
	'CASSE_DIFFCASSA',
	Sum(Round([DiffCassa],2)) AS chf,
	Sum(Round([DiffCassa],4)) AS qty,
	1.0 as ExchangeRate
	FROM Accounting.vw_AllStockDiffCassa d 
	where d.GamingDate = @gaming
)b
order by b.nome
GO
