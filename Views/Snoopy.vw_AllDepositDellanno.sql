SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_AllDepositDellanno]
--WITH SCHEMABINDING
AS


--solo per la fine dell'anno
/*

SELECT top 100 percent 
	LastName, 
	FirstName, 
	BirthDate,
	CustInsertDate,
	Importo, 
	DepOnGamingDate, 
	case
	when DatePart(yy,d.DepOffGamingDate) > 2015 then null
	else d.DepOffGamingDate 
	end as DepOffGamingDate,
	cast('12.31.2015' as datetime) as CurrGamingdate
FROM    Snoopy.vw_AllDepositi d
where (d.DepOffGamingDate is null and DatePart(yy,d.DepOnGamingDate) < 2015)
or (DatePart(yy,d.DepOnGamingDate) = 2015)
or (DatePart(yy,d.DepOffGamingDate) = 2015)
order by DepOnGamingDate


*/
SELECT  top 100 percent 
	LastName, 
	FirstName, 
	BirthDate,
	CustInsertDate,
	Importo, 
	DepOnGamingDate, 
	DepOffGamingDate,
	GeneralPurpose.fn_GetGamingLocalDate2(
			GetUTCDate(),
			Datediff(hh,GetUTCDAte(),GetDate()),
			7--cassa centrale
	) AS CurrGamingDate
FROM    Snoopy.vw_AllDepositi d
where (d.DepOffGamingDate is null)
or (DatePart(yy,d.DepOnGamingDate) = DatePart(yy,GetDate()))
or (DatePart(yy,d.DepOffGamingDate) = DatePart(yy,GetDate()))
order by DepOnGamingDate
GO
