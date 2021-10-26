SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Managers].[msp_ShutdownAllApplications] 
AS
execute [GeneralPurpose].[usp_BroadcastMessage] 'ShutdownAll','fromSQL=''1'''

GO
