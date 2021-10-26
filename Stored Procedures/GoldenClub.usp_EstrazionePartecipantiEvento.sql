SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_EstrazionePartecipantiEvento]
@forceit bit
AS


declare @g DATETIME,@EventoID int

set @g = GeneralPurpose.fn_GetGamingLocalDate2(getUTCDate(),1,4)


select @EventoID=EventoID
from Marketing.tbl_Eventi
where GamingDate = @g

IF @EventoID IS NULL
begin
	raiserror('Nessun evento oggi!!',16,1)
	return 1
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EstrazionePartecipantiEvento

BEGIN TRY  



	declare @sql nvarchar(max)--,@EventoID INT
	--SET @EventoID = 245
	IF @forceit = 1 --redo the estrazione clear the old one
	begin
		UPDATE GoldenClub.tbl_PartecipazioneEventi 
		SET Winner = null
		WHERE EventoID = @EventoID AND Winner = 1
	END

	IF NOT EXISTS (SELECT CustomerID FROM GoldenClub.tbl_PartecipazioneEventi WHERE EventoID = @EventoID AND Winner = 1)
	BEGIN
		--do the estrazione
		SELECT @sql = 
		'UPDATE GoldenClub.PartecipazioneEventi
			SET [winner] = 1
		from GoldenClub.PartecipazioneEventi p,
		(select top ' + cast(ev.NumVincitori as nvarchar(16)) + ' 
		g.CustomerID,g.EventoID
		FROM GoldenClub.PartecipazioneEventi AS g 
		INNER JOIN GoldenClub.Members AS gc ON gc.CustomerID = g.CustomerID 
		INNER JOIN GoldenClub.EventiMarketing AS ev ON ev.EventoID = g.EventoID
		WHERE ev.EventoID = ' + cast(ev.EventoID as nvarchar(16)) + ' 
		and gc.GoldenClubCardID is not null
		group by g.CustomerID,g.EventoID
		order by newid()
		) c 
		WHERE c.[CustomerID] = p.CustomerID and c.EventoID = p.EventoID'
		FROM Marketing.tbl_Eventi AS ev 
		WHERE ev.EventoID = @EventoID



		EXEC sp_executesql @SQL  

	END

	--return the list of winners

	SELECT g.CustomerID,gc.GoldenClubCardID--,MIN(g.TimeStampUTC)
	from GoldenClub.tbl_PartecipazioneEventi g
	INNER JOIN GoldenClub.tbl_Members AS gc ON gc.CustomerID = g.CustomerID 
	WHERE EventoID = @EventoID AND g.Winner = 1
	group by g.CustomerID,gc.GoldenClubCardID
	ORDER BY DATEPART(ms,MIN(g.TimeStampUTC))

	COMMIT TRANSACTION trn_EstrazionePartecipantiEvento

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EstrazionePartecipantiEvento
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
