SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE       VIEW [Snoopy].[vw_AllRettificaRestituizioni]
AS
SELECT 
		rr.[PK_RettificaRestituzioneID]
      ,r.PK_RestituzioneID
	  ,rr.[InsertTimeStampUTC]
      ,GeneralPurpose.fn_UTCToLocal(1,rr.[InsertTimeStampUTC]) AS InsertOra
      ,r.[CustomerID]
	  ,c.LastName
	  ,c.FirstName
	  ,c.BirthDate
	  ,c.Sesso
      ,r.[RestUserAccessID]
      ,r.[RestGamingDate]
 	  ,r.[RappSorv]
     ,GeneralPurpose.fn_UTCToLocal(1,[RestTimeStampUTC]) AS OraRestituzione
	  ,r.[FK_RettificaRestituzioneID]
      ,'Restituzione diff cassa ' + s.Tag +' del '+ CONVERT (VARCHAR(32),rr.Gamingdate,103)  AS Causale
      ,rr.CHFCents
      ,rr.EURCents
      ,rr.GamingDate 
	  ,s.StockID
	  ,rr.FK_RespID AS RespID
	  ,u.LongName AS Responsabile
	  ,s.Tag
      ,GeneralPurpose.fn_UTCToLocal(1,rr.OraErroreUTC) AS OraErrore
	  ,rr.[Descrizione]
FROM [Accounting].[tbl_Rettifica_Restituzione] rr 
INNER JOIN [Snoopy].[tbl_CustomerRestituzioni] r ON rr.[PK_RettificaRestituzioneID] = r.[FK_RettificaRestituzioneID]
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = r.CustomerID
INNER JOIN CasinoLayout.Stocks s ON s.StockID = rr.FK_StockID
LEFT OUTER JOIN CasinoLayout.Users u ON u.UserID = rr.FK_RespID

GO
