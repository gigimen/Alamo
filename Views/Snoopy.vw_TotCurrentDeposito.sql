SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_TotCurrentDeposito]
--WITH SCHEMABINDING
AS
select [GeneralPurpose].fn_GetGamingLocalDate2(
		GetUTCDate(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GetUTCDate(),GetDate()),
		7 --Cassa Centrale StockTypeID 
		) as GamingDate,
	IsNull(Sum(Importo),0) as Totale
from Snoopy.vw_AllDepositi
where DepOffID is null
GO
