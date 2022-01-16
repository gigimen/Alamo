SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [CasinoLayout].[vw_TorneoPokerInCorso]
AS
SELECT [PK_TorneoID]
      ,[TorneoName]
      ,[InizioIscrizioni]
      ,[MaxDate]
      ,[PK_TPGiornataID]
      ,[GiornoName]
      ,[GamingDate]
      ,[PK_DayTypeID]
      ,[DayType]
      ,[TaxCents]
      ,[BuyInCents]
      ,[NGarantiti]
	  ,[EnableVincita]
	  ,[NRientri]
      ,[DisplayName]
  FROM [CasinoLayout].[vw_SvolgimentoTorneoPoker]
    --WHERE '2.25.2022' BETWEEN [InizioIscrizioni] AND [MaxDate] AND GamingDate >=  '2.25.2022'

  WHERE GeneralPurpose.fn_GetGamingDate(GETDATE(),0,10) BETWEEN [InizioIscrizioni] AND [MaxDate] AND GamingDate >= GeneralPurpose.fn_GetGamingDate(GETDATE(),0,10) 
GO
