SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [GeneralPurpose].[asm_OpenCloseTable] (@opne [bit], @tablename [nvarchar] (4000), @extraCommands [nvarchar] (4000), @ipAddr [nvarchar] (4000), @port [int])
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [Broadcaster].[CBroadcastFunction].[asm_OpenCloseTable]
GO
