SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [GeneralPurpose].[asm_Broadcast] (@guid [nvarchar] (4000), @version [tinyint], @ipAddr [nvarchar] (4000), @mask [nvarchar] (4000), @port [int], @payload [nvarchar] (4000))
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [Broadcaster].[CBroadcastFunction].[asm_Broadcast]
GO
