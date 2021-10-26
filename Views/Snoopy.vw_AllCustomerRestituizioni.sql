SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE   VIEW [Snoopy].[vw_AllCustomerRestituizioni]
AS
SELECT [PK_RestituzioneID]
      ,r.[InsertTimeStampUTC]
      ,r.[CustomerID]
	  ,c.LastName
	  ,c.FirstName
	  ,c.BirthDate
	  ,c.Sesso
      ,[RestUserAccessID]
      ,[RestGamingDate]
      ,GeneralPurpose.fn_UTCToLocal(1,[RestTimeStampUTC]) AS OraRestituzione
	  ,r.RappSorv
	  ,r.[NoVetoNotification]
	  ,r.FK_DenaroTrovatoID
	  ,r.[FK_RettificaRestituzioneID]
      ,CASE 
		WHEN d.PK_DenaroTrovatoID IS NOT NULL THEN 'Fermare e chiamare SMS e HC per denaro Trovato Rapp Nr. ' + CAST (d.PK_DenaroTrovatoID AS VARCHAR(32)) 
		WHEN rr.[PK_RettificaRestituzioneID] IS NOT NULL THEN 'Fermare e chiamare SMS e HC per errore di ' + s.Tag +' del '+ CONVERT (VARCHAR(32),rr.Gamingdate,103) + ' Rapp Nr. ' + CAST (rr.[PK_RettificaRestituzioneID] AS VARCHAR(32))  + ' Rapp Sorv. '
		ELSE
			NULL
		END 
		 + 
		 CASE WHEN r.RappSorv IS NULL THEN ''
		 ELSE ' Rapp Sorv. ' + CAST (r.RappSorv AS VARCHAR(32))
		 END
		AS Causale
      --,[Cognome]
      --,[Nome]
      ,CASE 
		WHEN d.PK_DenaroTrovatoID IS NOT NULL THEN d.CHFCents 
		WHEN rr.[PK_RettificaRestituzioneID] IS NOT NULL THEN rr.CHFCents 
		ELSE
			NULL
		END AS CHFCents
      ,CASE 
		WHEN d.PK_DenaroTrovatoID IS NOT NULL THEN d.EURCents 
		WHEN rr.[PK_RettificaRestituzioneID] IS NOT NULL THEN rr.EURCents 
		ELSE
			NULL
		END AS EURCents
      ,CASE 
		WHEN d.PK_DenaroTrovatoID IS NOT NULL THEN d.GamingDate 
		WHEN rr.[PK_RettificaRestituzioneID] IS NOT NULL THEN rr.GamingDate 
		ELSE
			NULL
		END AS InsertGamingDate
      ,CASE 
		WHEN d.PK_DenaroTrovatoID IS NOT NULL THEN GeneralPurpose.fn_UTCToLocal(1,d.TimeStampUTC) 
		WHEN rr.[PK_RettificaRestituzioneID] IS NOT NULL THEN GeneralPurpose.fn_UTCToLocal(1,rr.[InsertTimeStampUTC]) 
		ELSE
			NULL
		END AS InsertOra,
		 r.[FK_RettificaRestituzioneID] AS RettificaRestituzioneID,
		 r.FK_DenaroTrovatoID AS DenaroTrovatoID,
		 rr.FK_StockID AS RettificaStockID,
		 s.Tag AS RettificaTag,
		 rr.FK_RespID	AS RettificaRespID,
		 u.[LongName]	AS RettificaResp

FROM [Snoopy].[tbl_CustomerRestituzioni] r
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = r.CustomerID
LEFT OUTER JOIN Accounting.tbl_DenaroTrovato d ON d.PK_DenaroTrovatoID = r.FK_DenaroTrovatoID
LEFT OUTER JOIN [Accounting].[tbl_Rettifica_Restituzione] rr ON rr.[PK_RettificaRestituzioneID] = r.[FK_RettificaRestituzioneID]
LEFT OUTER JOIN CasinoLayout.Stocks s ON s.StockID = rr.FK_StockID
LEFT OUTER JOIN CasinoLayout.Users u ON u.UserID = rr.FK_RespID

GO
