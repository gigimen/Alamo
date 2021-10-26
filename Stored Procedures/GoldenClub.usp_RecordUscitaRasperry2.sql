SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_RecordUscitaRasperry2]
AS

DECLARE @RC int
DECLARE @siteID int
DECLARE @increment int
DECLARE @TotUscite int

set @siteID = 51 --sesam entrata 1

set @increment = 1

EXECUTE @RC = [GoldenClub].[usp_RecordUscita] 
   @siteID
  ,@increment
  ,@TotUscite OUTPUT

return @RC
GO
GRANT EXECUTE ON  [GoldenClub].[usp_RecordUscitaRasperry2] TO [rasSesam3]
GO
