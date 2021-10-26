SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[DenaroTrovato]
AS
SELECT [PK_DenaroTrovatoID] AS Rap_ID
      ,[GamingDate]			AS Rap_GamingDate
      ,[NumeroRapporto]		AS Rap_NumeroRapporto
      ,[OraLoc]				AS Rap_Ora
      ,CAST([CHFCents] AS FLOAT ) /100.0 AS Rap_importoCHF
      ,CAST([EURCents] AS FLOAT ) /100.0 AS Rap_importoEuro
	  ,0					AS Rap_NumeroCHL
      ,[LuogoRitrovo]		AS Rap_LuogoRitrovo
      ,[Osservazioni]		AS Rap_Osservazioni
      ,[Trovatore]			AS Rap_Descrizione
      ,[ImportiInf10]		AS Rap_ImportiInf
      ,[LastName]			AS Rap_CognomeCliente
      ,[FirstName]			AS Rap_NomeCliente
--      ,[CustomerID]
 --     ,[BirthDate]
 --     ,[PK_RestituzioneID]
      ,[RestGamingDate]		AS Rap_Datarestituzione
	  ,[DataControllo]		AS Rap_Datacontrollo
	  ,NULL					AS Rap_Datatronc
	  ,cast(1	AS BIT)				AS Rap_Denaro
	  ,cast(0	AS BIT)				AS Rap_CHL
	  ,cast(0	AS BIT)				AS Rap_Ticket
	  ,cast(NULL AS NVARCHAR(50))	AS Rap_Tavolo
	  ,cast(NULL AS NVARCHAR(50))	AS Rap_NoSlot
	  ,cast(NULL AS NVARCHAR(50))	AS Rap_Identificazione
	  ,cast(NULL AS datetime)		AS [Rap-DataVersamento]
	  ,cast(NULL AS NVARCHAR(50))	AS Rap_NumeroTicket
	  ,cast(0	AS BIT)				AS Rap_RapportoAnnullato
	  ,cast(0	AS BIT)				AS Rap_ChipsEuro
	  ,cast(0	AS BIT)				AS Rap_TicketEuro
  FROM [Accounting].[vw_AllDenaroTrovato]
GO
