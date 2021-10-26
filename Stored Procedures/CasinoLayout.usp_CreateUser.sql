SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [CasinoLayout].[usp_CreateUser]
@FirstName			varchar(50),
@LastName			varchar(50),
@loginName			varchar(50),
@EmailAddress		varchar(50),
@BeginDate			smalldatetime,
@EndDate			smalldatetime,
@UserID				int output
AS



if @FirstName is null or len(@FirstName) = 0
begin
	raiserror('Must specify a valid @FirstName',16,-1)
	return (1)
END

if @LastName is null or len(@LastName) = 0
begin
	raiserror('Must specify a valid @LastName',16,-1)
	return (1)
END

if @loginName is null or len(@loginName) = 0
begin
	raiserror('Must specify a valid @loginName',16,-1)
	return (1)
END

if @BeginDate is null 
begin
	raiserror('Must specify a valid @BeginDate',16,-1)
	return (1)
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateUser

BEGIN TRY  

	insert into [CasinoLayout].[Users]  
	(
	FirstName    ,
	LastName		 ,
	loginName     ,
	EmailAddress  ,
	BeginDate	 ,
	EndDate		) 
	VALUES( 
		@FirstName		,
		@LastName		,
		@loginName		,
		@EmailAddress	,
		@BeginDate		,	
		@EndDate ); 
	
	
	set @UserID = SCOPE_IDENTITY() 


COMMIT TRANSACTION trn_CreateUser

END TRY  
BEGIN CATCH  
	DECLARE @err INT
	ROLLBACK TRANSACTION trn_CreateUser		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH


return @ret
GO
