SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [Managers].[msp_GetCKEntrance]
@GamingDate datetime,
@entrances	int output,
@vis		int output,
@gc			int output,
@gcUno		int output,
@membri		int output,
@membriUno	int output
AS
/*
A partire dal 20.1.2017 separiamo le visite dalle entrate
visite:		piu' visite dello stesso cliente valgono una entrata sola per la giornata
entrate:	piu' visite dello stesso cliente valgono ognuna 1 entrata nel computo della giornata
*/

/*

10.10.2019: C'è un errore perchè i clienti alamo presi dalla lista (senza passare dalla lettura della carta)
se entravano piú volte venivano contati come piú visite.


select @entrances = count(*),@vis = count(*)
from Snoopy.SesamControls c
inner join CasinoLayout.Sites s on s.SiteID = c.SiteID 
INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
where GamingDate = @GamingDate and st.SiteTypeID = 2  --count only sesam entrances

--add to entrance all card swapped (ckey query not used)
select @entrances += count(*),@vis += count(distinct CustomerID)
FROM GoldenClub.Ingressi e
INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
where GamingDate = @GamingDate and CardID is not null  and  s.SiteTypeID = 2  --count all research done only at sesam

--return also all entrate of goldenClub members, gross total and per customer based
select @gc =  count(*),@gcUno = count(distinct CustomerID)
from GoldenClub.vw_AllEntrateGoldenClub
where GamingDate = @GamingDate and IsSesamEntrance = 1

select @membri = count(*), @membriUno = count(distinct CustomerID)
from GoldenClub.vw_AllEntrateGoldenClub
where GamingDate = @GamingDate 
AND CancelID IS null
and GoldenClubCardID is not null 
and IsSesamEntrance = 1
*/

/*
SELECT  @entrances = [SesamControls]  - [PickedFromList] + [IngressiAlamo]
      ,@vis = [SesamControls]  - [PickedFromList] + [VisiteAlamo]
      ,@gc =[IngressiAlamo] 
      ,@gcUno = [VisiteAlamo]
      , @membri = [IngressiMembri]
      ,@membriUno = [VisiteMembri]
  FROM [GoldenClub].[vw_CKEntrancesByGamingDate]
  WHERE GamingDate = @GamingDate
  
*/

SELECT  @entrances = [SesamControls] + [IngressiAlamo]
      ,@vis = [SesamControls] + [VisiteAlamo]
      ,@gc =[IngressiAlamo] 
      ,@gcUno = [VisiteAlamo]
      , @membri = [IngressiMembri]
      ,@membriUno = [VisiteMembri]
  FROM [GoldenClub].[vw_CKEntrancesByGamingDate]
  WHERE GamingDate = @GamingDate
 
 IF @entrances	 IS NULL SET @entrances	 = 0
 IF @vis		 IS NULL SET @vis		 = 0
 IF @gc			 IS NULL SET @gc			 = 0
 IF @gcUno		 IS NULL SET @gcUno		 = 0
 IF @membri		 IS NULL SET @membri		 = 0
 IF @membriUno	 IS NULL SET @membriUno	 = 0
GO
