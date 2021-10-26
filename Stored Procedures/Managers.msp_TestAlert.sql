SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Managers].[msp_TestAlert]
AS
	raiserror(50001,18,1,'diciannove')

GO
