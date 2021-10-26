SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [SQLWebAPI].[asm_DOSGroup_AddPoint] (@UserKey [nvarchar] (4000), @password [nvarchar] (4000), @token [nvarchar] (4000), @cardid [int])
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLWebAPI].[CSQLWebAPI].[asm_DOSGroup_AddPoint]
GO
