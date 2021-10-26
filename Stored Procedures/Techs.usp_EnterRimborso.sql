SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Techs].[usp_EnterRimborso] 
@InterventoID		INT,
@AmountCents		INT,
@CustomerID			int,
@IDDocID			INT,
@slotTransID		INT OUTPUT,
@TimeStampLoc		DATETIME OUTPUT
AS

if not exists(select InterventoID from Techs.RapportiTecnici where InterventoID = @InterventoID)
begin
	raiserror('Intervento (%d) non ha un rapporto tecnico!',16,1,@InterventoID)
	return 1
END

--get the slot number
DECLARE @SlotNr			INT


SELECT @SlotNr = IpAddr
FROM [Techs].[tbl_InterventiSlot_SlotsDRGT]
where InterventoID = @InterventoID	
if @SlotNr IS null
begin
	raiserror('Cannot get SlotNr for interventoID (%d)!! ',16,1,@InterventoID)
	return 1
END

if @CustomerID is null or not exists (select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustomerID)
begin
	raiserror('Invalid CustomerID (%d) specified',16,1,@CustomerID)
	return (2)
end
if @IDDocID is null or not exists (select IDDocumentID from Snoopy.tbl_IDDocuments where IDDocumentID = @IDDocID and CustomerID = @CustomerID)
begin
	raiserror('Invalid IDDocumentID (%d) specified',16,1,@IDDocID)
	return (2)
end

IF @AmountCents is null or @AmountCents <= 0
begin
	raiserror('Invalid [@AmountCents] specified',16,1)
	return (2)
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterRimborso

BEGIN TRY  
	
	SET @TimeStampLoc = GETUTCDATE()

	if not exists (select InterventoID from [Techs].[Rimborsi] where InterventoID = @InterventoID) 
	--we ave to create the rapporto tecnico
	begin

		--insert now the entry in table [Techs].[InterventiSlot]
		INSERT INTO [Techs].[Rimborsi]
				   ([InterventoID]
				   ,[TimeStampUTC]
				   ,[CustomerID]
				   ,IDDocumentID)
			 VALUES
				   (@InterventoID
				   ,@TimeStampLoc
				   ,@CustomerID
				   ,@IDDocID
				   )
	end
	else
	begin
		UPDATE [Techs].[Rimborsi]
		SET [CustomerID] = @CustomerID
		  ,IDDocumentID = @IDDocID
		WHERE [InterventoID] = @InterventoID

	end

	DECLARE @RC int
	EXECUTE @RC = [Accounting].[usp_SlotTransaction] 
	   17 --@OpTypeID
	  ,@SlotNr
	  ,@TimeStampLoc
	  ,@AmountCents
	  ,null --@lfid
	  ,null --@jpID
	  ,null --@pin
	  ,null --@instance
	  ,@InterventoID
	  ,@slotTransID OUTPUT
	  ,@TimeStampLoc OUTPUT



	COMMIT TRANSACTION trn_EnterRimborso

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterRimborso
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
