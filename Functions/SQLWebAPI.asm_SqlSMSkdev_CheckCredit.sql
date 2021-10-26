SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [SQLWebAPI].[asm_SqlSMSkdev_CheckCredit] (@url [nvarchar] (4000), @UserKey [nvarchar] (4000), @password [nvarchar] (4000))
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLWebAPI].[CSQLWebAPI].[asm_SqlSMSkdev_CheckCredit]
GO
