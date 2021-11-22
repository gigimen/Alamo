SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_TestFeelGood]
AS

	EXEC	[GeneralPurpose].[usp_BroadcastMessage]
			@type = N'wav',
			@attribs = N'filename=''feelgood.wav'''
	

GO
