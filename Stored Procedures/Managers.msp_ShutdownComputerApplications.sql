SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Managers].[msp_ShutdownComputerApplications] 
@CompName varchar(64),
@Appid int
AS
declare @attribs varchar(512)
set @attribs = 'app=''' + cast(@Appid AS VARCHAR(32)) + ''''

if @CompName is not null and len(@CompName) > 0
	set @attribs = @attribs + ' comp=''' + @CompName + ''''

execute [GeneralPurpose].[usp_BroadcastMessage] 'Shutdown',@attribs
GO
