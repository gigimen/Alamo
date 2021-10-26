SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Snoopy].[vw_AllDenaroTrovato]
--WITH SCHEMABINDING
AS
SELECT lf.LifeCycleID,
		lf.StockID,
		lf.GamingDate,
		[Rap_ID]
      ,[Rap_NumeroRapporto]
      ,[Rap_GamingDate]
      ,[Rap_Ora]
      ,[Rap_NomeCliente]
      ,[Rap_CognomeCliente]
      ,[Rap_ImportoCHF]
      ,[Rap_ImportoEuro]
      ,[Rap_NumeroCHL]
      ,[Rap_LuogoRitrovo]
      ,[Rap_Osservazioni]
      ,[Rap_Datarestituzione]
      ,[Rap_Datacontrollo]
      ,[Rap_Datatronc]
      ,[Rap_Denaro]
      ,[Rap_CHL]
      ,[Rap_Tavolo]
      ,[Rap_NoSlot]
      ,[Rap_ImportiInf]
      ,[Rap_Descrizione]
      ,[Rap_Identificazione]
      ,[Rap-DataVersamento]
      ,[Rap_Ticket]
      ,[Rap_NumeroTicket]
      ,[Rap_RapportoAnnullato]
      ,[Rap_ChipsEuro]
	  ,CAST(CASE WHEN lf.Gamingdate = dt.Rap_GamingDate THEN 1 ELSE 0 END AS BIT) AS TrovatoToday
	  ,CAST(CASE WHEN lf.Gamingdate = dt.Rap_Datarestituzione THEN 1 ELSE 0 END AS BIT) AS RestituitoToday
FROM Snoopy.tbl_DenaroTrovato dt
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.StockID = 46 --just main cassa
--it has been trovato or restituito today
AND (dt.Rap_GamingDate = lf.GamingDate OR dt.Rap_Datarestituzione = lf.GamingDate)


GO
