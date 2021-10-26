SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [GeneralPurpose].[asm_SendToCIS] (@cisCommand [nvarchar] (4000), @ipAddr [nvarchar] (4000), @port [int])
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [Broadcaster].[CBroadcastFunction].[asm_SendToCIS]
GO
