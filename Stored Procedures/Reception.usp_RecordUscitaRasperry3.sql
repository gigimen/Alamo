SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Reception].[usp_RecordUscitaRasperry3]
AS

DECLARE @RC int
DECLARE @siteID int
DECLARE @increment int
DECLARE @TotUscite int

set @siteID = 52 --sesam balconata lato sfizio

set @increment = 1

EXECUTE @RC = GoldenClub.usp_RecordUscita 
   @siteID
  ,@increment
  ,@TotUscite OUTPUT

return @RC
GO
GRANT EXECUTE ON  [Reception].[usp_RecordUscitaRasperry3] TO [rasSesam3]
GO
