SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_GetStatoDeposito]
(
      @GamingDate DATETIME
)

RETURNS @r TABLE (
	LastName			varchar(50), 
	FirstName			varchar(50), 
	BirthDate			datetime,
	CustInsertDate		datetime,
	Importo				float, 
	DepOnGamingDate		datetime, 
	DepOffGamingDate	datetime,
	CurrGamingdate		datetime
	)
BEGIN
/*

select * from [Accounting].[fn_GetStatoDeposito] ('4.15.2019')

*/
/*


declare @GamingDate datetime
set @GamingDate = '5.1.2019'

declare @r TABLE (
	LastName			varchar(50), 
	FirstName			varchar(50), 
	BirthDate			datetime,
	CustInsertDate		datetime,
	Importo				float, 
	DepOnGamingDate		datetime, 
	DepOffGamingDate	datetime,
	CurrGamingdate		datetime
	)
--*/




INSERT INTO @r
SELECT  
	LastName, 
	FirstName, 
	BirthDate,
	CustInsertDate,
	Importo, 
	DepOnGamingDate, 
	case when DepOffGamingDate > @GamingDate then null else DepOffGamingDate end as DepOffGamingDate,
	@GamingDate as CurrGamingdate
FROM Snoopy.vw_AllDepositi d
where 
d.DepOffGamingDate = @GamingDate 
or d.DepOnGamingDate = @GamingDate
or (d.DepOnGamingDate < @GamingDate and (d.DepOffGamingDate > @GamingDate or d.DepOffGamingDate is null) )
order by DepOnGamingDate

--select * from @r

      RETURN 
END
GO
