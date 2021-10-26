SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [GoldenClub].[usp_EventiNewEntrata]
@custID int,
@evID int,
@siteid int,
@accomp int,
@tot int output,
@memb int output
AS


if @custID is null or not exists 
	(select CustomerID from GoldenClub.tbl_Members where CustomerID = @custID and CancelID is null and GoldenClubCardID is not null)
begin
	raiserror('%d is not a valid CustomerID or is not a Golden Club Member',16,1,@custID)
	return 1
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EventiNewEntrata

BEGIN TRY  


	insert into GoldenClub.tbl_PartecipazioneEventi
		(CustomerID,EventoID,SiteID,Accompagnatori)
		VALUES(@custid,@evID,@siteid,@accomp)

	select @tot = count(*) + SUM(Accompagnatori),@memb = count(*)
	from GoldenClub.tbl_PartecipazioneEventi
	where EventoID = @evID
	if @tot is null
		set @tot = 0

	declare @attribs varchar(4096)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' EventoID=''' + CAST(@evID as varchar(32)) +
		''' SiteID=''' + CAST(@siteID as varchar(32)) +
		''' Members=''' + CAST(@memb as varchar(32)) +
		''' Total=''' + CAST(@tot as varchar(32)) + ''''

	execute [GeneralPurpose].[usp_BroadcastMessage] 'PartecipaEvento',@attribs

	COMMIT TRANSACTION trn_EventiNewEntrata

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EventiNewEntrata
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
