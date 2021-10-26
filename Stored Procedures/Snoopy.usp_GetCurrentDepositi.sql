SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Snoopy].[usp_GetCurrentDepositi] 
@GamingDate datetime
AS
---
/*

declare @GamingDate datetime
set @GamingDate = '4.23.2017'
--*/

if @GamingDate is null
	set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(GetUTCDate(),1,7) --CC GamingDate

SELECT @GamingDate AS GamingDate,
		count(distinct[DepositoID]) As CountDepositi
		,min([DepOnGamingDate]) As MinGamingDate
		,max([DepOnGamingDate]) As MaxGamingDate
		,sum([Importo])			As Totale
		,sum([ImportoSfr])		As TotaleSfr
		,sum([ImportoEuro])		As TotaleEuro
from Snoopy.vw_AllDepositi 
where [DepOnGamingDate] <= @GamingDate 
and (
		DepOffGamingDate is null --still have to be prelevata 
		or
		DepOffGamingDate > @GamingDate --prelevate today
	)


	/*
	
SELECT *
from Snoopy.vw_allDepositi 
where [DepOnGamingDate] <= @GamingDate 
and (
		DepOffGamingDate is null --still have to be prelevata 
		or
		DepOffGamingDate > @GamingDate --prelevate today
	)
	*/
GO
