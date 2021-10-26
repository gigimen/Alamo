SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [ForIncasso].[usp_GetInfoblattAverageMonth]
@gaming DATETIME
AS

/*


declare @gaming DATETIME
set @gaming = '8.28.2020'
execute [ForIncasso].[usp_GetInfoblattAverageMonth] @gaming
--*/

declare @firstday datetime

set @firstday = dateadd(day ,- datepart(day,@gaming) + 1,@gaming)

print @gaming
print @firstday


declare @t table (
Game varchar(2),
GamingDate datetime,
TableCount		INT,
TableOpen		INT,
CashBox			FLOAT,	CashBoxCol		VARCHAR(2),
BSE				FLOAT,	BSECol			VARCHAR(2),
TroncTavoli		FLOAT,	TroncCol		VARCHAR(2),
TroncSala		FLOAT,	TroncsalaCol	VARCHAR(2),
Visite			INT,	VisiteCol		VARCHAR(2),
IntRate			FLOAT,	FxRateCol		VARCHAR(2),
Gastro		FLOAT,		GastroCol		VARCHAR(2)
)


declare @t2 table (
GamingDate	datetime,
CashBox		float,
TableCount	INT,
TableOpen	INT,
BSEAR		float,
BSEBJ		float,
BSEPB		float,
BSEUTH		float,
BSESB		float,
Tronc		float,
Visite		int
)
DECLARE @day DATETIME
SET @day = @firstday
while (@day <= @gaming)
begin
	insert into @t 
	EXECUTE [ForIncasso].[usp_GetInfoblatt] @day
	set @day = dateadd(day,1,@day)
end
--select * from @t

insert into @t2
(
	GamingDate	,
	TableCount	,
	TableOpen	,
	CashBox		,
	Tronc		,
	Visite		
)
select 
	GamingDate	,
	TableCount	,
	TableOpen	,
	CashBox		,
	TroncTavoli + TroncSala		,
	Visite	
from
(
	select 
		GamingDate,
		SUM(TableCount)		AS TableCount,
		SUM(TableOpen)		AS TableOpen,
		sum(CashBox)		AS CashBox,
		sum(TroncTavoli)	AS TroncTavoli, 
		troncSala,
		Visite 
	from @t
	group by GamingDate,troncSala,Visite
) a



update @t2
set BSEAR = a.BSE,
BSEBJ = b.BSE,
BSEPB = p.BSE,
BSEUTH = u.BSE,
BSESB = s.BSE--ISNULL(u.BSE,0)
from @t2 as t
FULL OUTER join
(
select gamingDate, BSE FROM @t where Game = 'AR'
)a ON a.GamingDate = t.GamingDate
FULL OUTER JOIN 
(
select gamingDate, BSE from @t where Game = 'BJ'
)b ON b.GamingDate = t.GamingDate
FULL OUTER join
(
select gamingDate, BSE from @t where Game = 'PB'
)p ON p.GamingDate = t.GamingDate
FULL OUTER join
(
select gamingDate, 
CASE WHEN gamingdate <= '7.14.2019' THEN NULL ELSE bse END AS BSE from @t where Game = 'UT'
)u ON u.GamingDate = t.GamingDate
FULL OUTER join
(
select gamingDate, 
CASE WHEN gamingdate <= '8.27.2020' THEN NULL ELSE bse END AS BSE from @t where Game = 'SB'
)s ON s.GamingDate = t.GamingDate

select * from @t2

select 
avg(CashBox ) as CashBox ,
MAX(TableCount)	AS TableCount,
MAX(TableOpen)	AS TableOpen,
avg(BSEAR	) as BSEAR	,
avg(BSEBJ	) as BSEBJ	,
avg(BSEPB	) as BSEPB	,
avg(BSEUTH	) as BSEUTH	,
avg(BSESB	) as BSESB	,
avg(Tronc	) as Tronc	,
avg(Visite	) as Visite	

from @t2

GO
