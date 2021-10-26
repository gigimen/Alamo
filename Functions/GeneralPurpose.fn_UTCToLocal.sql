SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [GeneralPurpose].[fn_UTCToLocal] (@utctoloc [bit], @UTCDate [datetime])
RETURNS [datetime]
WITH EXECUTE AS CALLER
EXTERNAL NAME [UTCToLocal].[UTCToLocal.UTCToLocal].[ConvertUTCToLocal]
GO
