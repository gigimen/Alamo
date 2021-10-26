SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [SQLWebAPI].[usp_CheckCredit] @c varchar(256) = NULL OUTPUT ,@credits float = NULL OUTPUT 
AS

	SET @credits = -1
	DECLARE @UserKey NVARCHAR(4000),@password NVARCHAR(4000),@url NVARCHAR(4000)

	SELECT @url = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'SMSkdevURL'
	if @url is null OR LEN(@url) = 0
	begin
		raiserror('Errore in lettura SMSurl in configurazione',16,1)
		return(1)
	END


	select @UserKey = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'SMSkdevUserKey'
	if @UserKey is null OR LEN(@UserKey) = 0
	begin
		raiserror('Errore in lettura SMSkdevUserKey in configurazione',16,1)
		return(1)
	END

	select @password = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'SMSkdevPassword'
	if @password is null OR LEN(@password) = 0
	begin
		raiserror('Errore in lettura SMSkdevPassword in configurazione',16,1)
		return(1)
	end

	begin try
		SELECT @c = [SQLWebAPI].[asm_SqlSMSkdev_CheckCredit](
			@url
		   ,@UserKey
		  ,@password)
		  print @c
		 PRINT REPLACE(right(@c,len(@c) - CHARINDEX(':',@c,0) - 1),CHAR(10),'')
		SET @credits = CAST(REPLACE(right(@c,len(@c) - CHARINDEX(':',@c,0) - 1),CHAR(10),'') AS float)

		RETURN 0	
	END try
	begin catch

		set @c = left(ERROR_MESSAGE(),256)

	end catch
	RETURN 1	

GO
GRANT EXECUTE ON  [SQLWebAPI].[usp_CheckCredit] TO [SolaLetturaNoDanni]
GO
