SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Managers].[msp_FixLocalUsers]
AS
EXEC sp_change_users_login 'Report'

EXEC sp_change_users_login 'Auto_Fix', 'chi.sei'

EXEC sp_change_users_login 'Auto_Fix', 'yogi.bubu'

EXEC sp_change_users_login 'Auto_Fix', 'WebTech'

EXEC sp_change_users_login 'Auto_Fix', 'pingu'

EXEC sp_change_users_login 'Auto_Fix', 'tecnici'

EXEC sp_change_users_login 'Report'

UPDATE [GeneralPurpose].[ConfigParams] SET VarValue = 53701 WHERE VarName = 'AlamoMessagesPort'
GO
