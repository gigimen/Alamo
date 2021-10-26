SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [GeneralPurpose].[GroupConcat] (@input [nvarchar] (200))
RETURNS [nvarchar] (max)
EXTERNAL NAME [GroupConcat].[Concatenate]
GO
