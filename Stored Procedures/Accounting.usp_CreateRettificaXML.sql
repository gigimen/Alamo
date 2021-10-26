SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CreateRettificaXML] 
@values				varchar(max),
@SnapshotTimeLoc	DATETIME output
AS

IF @values is null OR LEN(@values) = 0
begin
	raiserror('iNVALID @values specified',16,1)
	return 1
END



/*
declare @t as varchar(max)
set @t = '<ROOT><RETTIFICHE lfid="1">
	<RETTIFICA snapshotid="112345" rettCHF="" Nota="Questa è una nota" />
	<RETTIFICA snapshotid="11235" rettEUR="0" rettCHF="124" Nota="Questa è una nota" />
	<RETTIFICA snapshotid="11345" rettEUR="200" rettCHF="" Nota="Questa è una nOat" />
</RETTIFICHE></ROOT>'
declare @XML xml = @t
select 
T.N.value('../@lfid', 'int') as lfid,
T.N.value('@snapshotid', 'int') as snapshotid,
T.N.value('@rettEUR', 'int') as rettEUR,
T.N.value('@rettCHF', 'int') as rettCHF,
T.N.value('@Nota', 'varchar(256)')  as Nota
from @XML.nodes('ROOT/RETTIFICHE/RETTIFICA') as T(N)
*/

set @SnapshotTimeLoc = GetUTCDate()

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateRettifica

BEGIN TRY  
	DECLARE @XML xml = @values,
	@lifecycleid int,
	@snapshotid int,
	@rettEUR int,
	@rettCHF INT ,
	@Nota VARCHAR(256) 

	SELECT @lifecycleid = T.N.value('@lifecyleid', 'int') 
	from @XML.nodes('ROOT/RETTIFICHE') as T(N)
	IF @lifecycleid is null 
	begin
		raiserror('iNVALID @lifecycleid specified',16,1)
		return 1
	END

	declare exclu_cursor cursor for
		select 
			T.N.value('@snapshotid', 'int') as snapshotid,
			T.N.value('@rettEUR', 'int') as rettEUR,
			T.N.value('@rettCHF', 'int') as rettCHF,
			T.N.value('@Nota', 'varchar(256)')  as Nota
		from @XML.nodes('ROOT/RETTIFICHE/RETTIFICA') as T(N)


	Open exclu_cursor

	Fetch Next from exclu_cursor into 	@snapshotid ,	@rettEUR ,	@rettCHF  ,	@Nota  

	While @@FETCH_STATUS = 0 
	Begin
		IF NOT exists (
			SELECT [FK_LifeCycleID] FROM [Accounting].[tbl_Rettifiche]
			WHERE [FK_LifeCycleID] = @LifeCycleID AND [FK_LifeCycleSnapshotID] = @snapshotid
		)
			--new rettifica to be created
			INSERT INTO [Accounting].[tbl_Rettifiche]
					   ([FK_LifeCycleID]
					   ,[FK_LifeCycleSnapshotID]
					   ,[EURCents]
					   ,[CHFCents]
					   ,[Nota]
					   ,[TimeStampUTC])
			VALUES (
				@lifecycleid ,
				@snapshotid ,
				@rettEUR ,
				@rettCHF  ,
				@Nota ,
				@SnapshotTimeLoc
				)
		ELSE
			--exisiting retttifica to updated
			UPDATE [Accounting].[tbl_Rettifiche]
			   SET [EURCents] = @rettEUR
				  ,[CHFCents] = @rettCHF
				  ,[Nota] = @Nota
				  ,[TimeStampUTC] = @SnapshotTimeLoc
			 WHERE [FK_LifeCycleID] = @LifeCycleID AND [FK_LifeCycleSnapshotID] = @snapshotid
		
		Fetch Next from exclu_cursor into 	@snapshotid ,	@rettEUR ,	@rettCHF  ,	@Nota  
	End

	close exclu_cursor
	deallocate exclu_cursor

	--delete rettifiche no more present
	DELETE FROM Accounting.tbl_Rettifiche
	WHERE [FK_LifeCycleID] = @LifeCycleID AND [FK_LifeCycleSnapshotID] NOT IN
    (
		select 
		T.N.value('@snapshotid', 'int') as snapshotid
		from @XML.nodes('ROOT/RETTIFICHE/RETTIFICA') as T(N)
	)
	COMMIT TRANSACTION trn_CreateRettifica

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateRettifica		
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
