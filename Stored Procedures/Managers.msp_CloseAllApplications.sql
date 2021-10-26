SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Managers].[msp_CloseAllApplications] 
@AppID int
AS
--
declare @CompName varchar(64)
DECLARE reg_cursor CURSOR
   FOR
	select ComputerName	from CasinoLayout.vw_WhoDoesWhatWhere where ApplicationID = @AppID
OPEN reg_cursor
FETCH NEXT FROM reg_cursor INTO @CompName
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	execute [Managers].[msp_ShutdownComputerApplications] @compName,@appid
   FETCH NEXT FROM reg_cursor INTO  @compName
END
declare @ret int
set @ret = CURSOR_STATUS ('global','reg_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar) 
if @ret > -3
begin
--	print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end
GO
