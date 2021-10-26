SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [GeneralPurpose].[usp_BroadcastMessage] 
@type varchar(32),
@attribs varchar(1024)
AS
IF @type IS NULL OR LEN(@type) = 0 OR @attribs IS NULL OR LEN(@attribs)=0
BEGIN
	IF @type IS NULL 
		INSERT INTO [Managers].[tbl_Errors] ([Dove],ErrDescription) VALUES( '[GeneralPurpose].[usp_BroadcastMessage] ','null type specified')
	
	ELSE
		INSERT INTO [Managers].[tbl_Errors] ([Dove],ErrDescription) VALUES( '[GeneralPurpose].[usp_BroadcastMessage] ',@type + ' null attrib specified')
	
	RETURN 0
END
BEGIN TRY

	DECLARE @ret NVARCHAR(4000)
	SELECT @ret = [GeneralPurpose].[fn_BroadcastMessage](@type,@attribs )

	IF SUBSTRING(@ret,1,2) <> 'OK'
	BEGIN
		RAISERROR(@ret,16,1)
		RETURN (1)
	END
END TRY  
BEGIN CATCH  
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	RETURN (2)

END CATCH	

RETURN 0
GO
