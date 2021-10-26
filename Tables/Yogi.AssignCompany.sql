CREATE TABLE [Yogi].[AssignCompany]
(
[Id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[IdBadgeNumber] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[IdCompanyContact] [int] NOT NULL,
[DataStart] [smalldatetime] NOT NULL,
[DataEnd] [smalldatetime] NULL,
[Note] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Signature] [image] NULL,
[IdUserStart] [int] NOT NULL,
[IdUserEnd] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [Yogi].[trg_CheckOverAssignCompanyInsert] ON [Yogi].[AssignCompany]
   INSTEAD OF INSERT
AS 
BEGIN

	IF NOT EXISTS(
        SELECT 1
        FROM INSERTED
    ) 
	begin
		RAISERROR('NO ROW IN INSERT', 16, 1)
		return
	end
	SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @IdID          	 int
	DECLARE @IdBadgeNumber    varchar(50)
	DECLARE @IdCompanyContact int
	DECLARE @DataStart		  datetime
	DECLARE @DataEnd		  datetime
	DECLARE @Note			  varchar(255)
	DECLARE @IdUserStart      int
	DECLARE @IdUserEnd		  int


    DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
	SELECT 
		i.id
	  ,[IdBadgeNumber]
      ,[IdCompanyContact]
      ,[DataStart]
      ,[DataEnd]
	  ,[Note]
	  ,[IdUserStart]
	  ,[IdUserEnd]	
    FROM INSERTED i

    OPEN cur

    FETCH NEXT FROM cur INTO
	    @IdID
	    , @IdBadgeNumber	
        , @IdCompanyContact		
        , @DataStart	
        , @DataEnd	
		, @Note
		, @IdUserStart
		, @IdUserEnd

    WHILE @@FETCH_STATUS = 0
    BEGIN

	-- Se definita la dataend deve essere >= datastart
	if @DataEnd is not null and @DataEnd < @DataStart
	begin
			raiserror('INSERT: @DataEnd is before @DataStart',16 ,1)
			RETURN	
	end


	-- Se @IdBadge o gia presente con dataend null o posteriore a datastart nella tabella Assing User
	if exists( 
		select Id from [Yogi].[AssignUser] where IdBadgeNumber = @IdBadgeNumber 
		and
		(
			DataEnd is null or
			DataEnd > @DataStart
		)
	
	) 
	begin
			raiserror('INSERT: IdBadge(%d) is already assigned for the specified period',16 ,1 ,@IdBadgeNumber)
			RETURN	
	end

	-- Se @IdBadge o gia presente con dataend null o posteriore a datastart nella tabella corrente
	if exists( 
		select Id from [Yogi].[AssignCompany] where IdBadgeNumber = @IdBadgeNumber  
		and
		(
			DataEnd is null or
			DataEnd > @DataStart
		)
	
	) 
	begin
			raiserror('INSERT: IdBadge(%d) is already assigned for the specified period in to the company',16 ,1 ,@IdBadgeNumber)
			RETURN	
	end

	--qui la vera insert
	
	INSERT INTO [Yogi].[AssignCompany]
           (
		    [IdBadgeNumber]
           ,[IdCompanyContact]
           ,[DataStart]
           ,[DataEnd]
           ,[Note]
		   ,[IdUserStart]
		   ,[IdUserEnd]	)
     VALUES
           (		  
		  @IdBadgeNumber	
        , @IdCompanyContact		
        , @DataStart	
        , @DataEnd	
		, @Note
		, @IdUserStart
		, @IdUserEnd	
	)
	

    FETCH NEXT FROM cur INTO
		  @IdID
	    , @IdBadgeNumber	
        , @IdCompanyContact		
        , @DataStart	
        , @DataEnd	
		, @Note
		, @IdUserStart
		, @IdUserEnd

    END

    CLOSE cur
    DEALLOCATE cur


END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [Yogi].[trg_CheckOverAssignCompanyUpdate] ON [Yogi].[AssignCompany]
   INSTEAD OF UPDATE
AS 
BEGIN

	IF NOT EXISTS(
        SELECT 1
        FROM INSERTED
    ) 
	begin
		RAISERROR('NO ROW IN INSERT', 16, 1)
		return
	end
	SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @Id				  int
	DECLARE @IdBadgeNumber    varchar(50)
	DECLARE @IdCompanyContact int
	DECLARE @DataStart		  datetime
	DECLARE @DataEnd		  datetime
	DECLARE @Note			  varchar(255)
	DECLARE @IdUserStart      int
	DECLARE @IdUserEnd        int


    DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
	SELECT 
	   [Id]
	  ,[IdBadgeNumber]
      ,[IdCompanyContact]
      ,[DataStart]
      ,[DataEnd]
	  ,[Note]
	  ,[IdUserStart]
	  ,[IdUserEnd]
    FROM INSERTED i

    OPEN cur

    FETCH NEXT FROM cur INTO
		  @Id	
		, @IdBadgeNumber	
        , @IdCompanyContact		
        , @DataStart	
        , @DataEnd	
		, @Note
		, @IdUserStart
		, @IdUserEnd

    WHILE @@FETCH_STATUS = 0
    BEGIN

	-- Se definita la dataend deve essere >= datastart
	if @DataEnd is not null and @DataEnd < @DataStart
	begin
			raiserror('UPDATE: @DataEnd is before @DataStart',16 ,1)
			RETURN	
	end

	--qui la vera update
	
	UPDATE [Yogi].[AssignCompany]
	   SET  
		  [IdBadgeNumber] = @IdBadgeNumber	
        , [IdCompanyContact] = @IdCompanyContact		
        , [DataStart] = @DataStart	
        , [DataEnd] = @DataEnd	
		, [Note] = @Note
		, [IdUserStart] = @IdUserStart
		, [IdUserEnd] = @IdUserEnd
	WHERE [Id] = @Id 
	

   FETCH NEXT FROM cur INTO
		  @Id	
		, @IdBadgeNumber	
        , @IdCompanyContact		
        , @DataStart	
        , @DataEnd	
		, @Note
		, @IdUserStart
		, @IdUserEnd

    END

    CLOSE cur
    DEALLOCATE cur


END
GO
ALTER TABLE [Yogi].[AssignCompany] ADD CONSTRAINT [PK_AssignCompany] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
