SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [GeneralPurpose].[usp_EmailCKEntrance] 
@final bit,
@rec varchar(max),
@cc varchar(max) = null,
@bcc varchar(max) = 'lmenegolo@cmendrisio.office.ch'
as
/*




declare 
@final bit,
@rec varchar(max),
@cc varchar(max),
@bcc varchar(max)

set @final = 1

set @rec = 'lmenegolo@cmendrisio.office.ch'
set @cc = null


DECLARE	@return_value int


EXEC	@return_value = [GeneralPurpose].[usp_EmailCKEntrance]
		1,
		'lmenegolo@cmendrisio.office.ch',
		NULL,--'acamponovo@cmendrisio.office.ch;cesposito@cmendrisio.office.ch',
		NULL--'lmenegolo@cmendrisio.office.ch;stettamanti@cmendrisio.office.ch'

SELECT	'Return Value' = @return_value


--*/

declare @body varchar(2048)


declare @gaming datetime
SELECT  @gaming = [GeneralPurpose].[fn_GetGamingDate] (GETDATE(),0,12)

print @gaming
declare 
@entr int
,@vis int
,@gc int
,@gcUno int
,@membri	int
,@membriUno	int
,@CambiRedCount int
,@CambiRedTot int
,@ret INT


execute @ret = Managers.msp_GetCKEntrance 
	@gaming,
	@entr 		output,
	@vis		output,	
	@gc 		output,
	@gcUno 		OUTPUT,
	@membri		OUTPUT,
	@membriUno	OUTPUT
    
SELECT 	@gaming,
	@entr 		,
	@vis		,	
	@gc 		,
	@gcUno 		,
	@membri		,
	@membriUno	

IF @ret <> 0
BEGIN 
exec msdb.dbo.[sp_send_dbmail]
   @recipients                 = 'it@cmendrisio.office.ch;acamponovo@cmendrisio.office.ch', 
   @subject                    = 'ERRORE Aggiornamento Database CK_entrance',
   @body                       = @body

END

SELECT 
	@CambiRedCount = isnull(sum([AcquistiDaRedemption]),0),
    @CambiRedTot  =  isnull(sum([TotEuros]),0)
FROM [GoldenClub].[vw_CustomerEuroRedeemable]


if exists(select * from Snoopy.tbl_EntrateSummary where gamingdate = @gaming)
	UPDATE Snoopy.tbl_EntrateSummary
	set Entrances = @entr,
		Visite = @vis,
		GoldenClub = @gc,
		GoldenClubUno = @gcUno,
		Membri	= @membri,
		MembriUno = @membriUno,
		CambiEuroRedeemableCount = @CambiRedCount,
		CambiEuroRedeeemableTot = @CambiRedTot 
	where GamingDate = @gaming
else
	INSERT INTO Snoopy.tbl_EntrateSummary
		(
			GamingDate,
			Entrances,
			Visite,
			GoldenClub,
			GoldenClubUno,
			Membri,
			MembriUno,
			CambiEuroRedeemableCount,
			CambiEuroRedeeemableTot
		)
		values(
			@gaming		,
			@entr		,
			@vis		,
			@gc			,
			@gcUno		,	
			@membri		,
			@membriUno	,
			@CambiRedCount,
			@CambiRedTot 
			)

set @body = 
'Ultimo aggionamento dati Sesam per il gamingdate ' + convert(varchar(32),@gaming,103) + '
	Entrate	 = '				+ cast (@entr		 as varchar(16)) + '
	Visite	 = '				+ cast (@vis		 as varchar(16)) + '
	GoldenClub = '				+ cast (@gc			 as varchar(16)) + '
	GoldenClubUno = '			+ cast (@gcUno		 as varchar(16)) + '
	Membri = '					+ cast (@membri		 as varchar(16)) + '
	MembriUno = '				+ cast (@membriUno	 as varchar(16)) + '
	CambiEuroRedeemableCount = '+ cast (@CambiRedCount as varchar(16)) + '
	CambiEuroRedeeemableTot = '	+ cast (@CambiRedTot as varchar(16)) + '

Per i dati storici consultare http://sr-servizi/EntrateCK/

GRAZIE E BUONA GIORNATA'

--print @body


exec [GeneralPurpose].[usp_EmailMessageEx] 
					'Aggiornamento Database CK_entrance SUCCESS',
					@body, 
					'l.menegolo@casinomendrisio.ch',--@rec, 
					NULL,--@cc,--'s.tettamanti@casinomendrisio.ch',
					NULL,--@bcc,
					'visite@cmendrisio.office.ch'
GO
