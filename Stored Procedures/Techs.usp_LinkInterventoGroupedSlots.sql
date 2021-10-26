SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF


CREATE procedure [Techs].[usp_LinkInterventoGroupedSlots] 
@interventoID		INT,
@groupName			VARCHAR(32)
AS

if not exists(select InterventoID from Techs.InterventiSlot where InterventoID = @interventoID)
begin
	raiserror('Invalid interventoID (%d) specified ',16,1,@interventoID)
	return 1
end

if @groupName IS null or LEN(@groupName) = 0
begin
	raiserror('Invalid GroupName specified ',16,1)
	return 1
END
if not exists (SELECT SlotGroupName FROM Techs.SlotGroups WHERE SlotGroupName = @groupName)
begin
	raiserror('Invalid GroupName (%s) specified ',16,1,@groupName)
	return 1
END


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_LinkInterventoGroupedSlots

BEGIN TRY  


	--delete all associated ramclear if any	
	delete from RAMClear where RAMClearID IN 
	(
		SELECT RAMClearID from [Techs].[InterventiSlot_Slots]
		WHERE [InterventoID] = @interventoID
	)
	
	--unlink all slots from the intervento
	delete from [Techs].[InterventiSlot_Slots]
	WHERE [InterventoID] = @interventoID

	--finally insert new entry
	INSERT INTO [Techs].[InterventiSlot_Slots]
			   ([InterventoID]
			   ,[COD_MACHIN]
			   ,[DAT_DDEF])
	VALUES
			   (@InterventoID
			   ,@groupName
			   ,GETDATE()
			   )

	COMMIT TRANSACTION trn_LinkInterventoGroupedSlots

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_LinkInterventoGroupedSlots
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret


GO
