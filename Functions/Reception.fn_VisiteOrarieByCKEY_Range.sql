SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Reception].[fn_VisiteOrarieByCKEY_Range]
(
	@GamingDateFrom			DATETIME,
	@GamingDateTo			DATETIME
)
RETURNS   @ret TABLE(
	[GamingDate]	datetime not null,
	[giorno]		INT not null,
	[ora]			INT not null,
	CKEY1			INT,
	CKEY2			INT,
	CKEY3           INT
	)

AS
BEGIN
/*


declare @GamingDateFrom			DATETIME
declare @GamingDateTo			DATETIME
set @GamingDateFrom = '10.1.2020'
set @GamingDateTo   = '10.30.2020'

select * from [Snoopy].[fn_VisiteOrarieByCKEY_Range] (@GamingDateFrom, @GamingDateTo)
--*/



INSERT INTO  @ret
(
	[GamingDate]	,
	[giorno]		,
	[ora]			,
	CKEY1,
	CKEY2,
	CKEY3
)

--declare @GamingDateFrom			DATETIME
--declare @GamingDateTo			DATETIME
--set @GamingDateFrom = '10.1.2020'
--set @GamingDateTo   = '10.30.2020'



SELECT 
ISNULL(c.GamingDate,v.GamingDate) as gamingdate,
ISNULL(c.giorno,v.giorno) as giorno,
ISNULL(c.ora,v.ora) as ora,
ISNULL(c.CKey1,0) + ISNULL(v.CKey1,0) as CKey1,
ISNULL(c.CKey2,0) + ISNULL(v.CKey2,0) as CKey2,
ISNULL(c.CKey3,0) + ISNULL(v.CKey3,0) as CKey3
FROM 
(
	SELECT  
		datepart(day,i.entratatimestampLoc) as giorno
	   ,datepart(hour,i.entratatimestampLoc) as ora
	   ,i.GamingDate
	   ,SUM(CASE When c.[SiteID]=49 Then 1 Else 0 End ) as CKey1  
	   ,SUM(CASE When c.[SiteID]=50 Then 1 Else 0 End ) as CKey2
	   ,SUM(CASE When c.[SiteID]=111 Then 1 Else 0 End ) as CKey3

	FROM Reception.tbl_FasceEtaRegistrations i
	INNER JOIN Reception.tbl_VetoControls c ON c.PK_ControllID = i.[FK_ControlID]
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2 and c.GamingDate >= @GamingDateFrom AND c.GamingDate <= @GamingDateTo --count only sesam entrances
	group by i.GamingDate,datepart(hour,i.entratatimestampLoc),datepart(day,i.entratatimestampLoc)

) c 
FULL OUTER JOIN 
(

		SELECT  datepart(day,e.entratatimestampLoc)		as giorno,
				datepart(hour,e.entratatimestampLoc)	as ora
	   ,SUM(CASE When e.[SiteID]=49 Then 1 Else 0 End ) as CKey1  
	   ,SUM(CASE When e.[SiteID]=50 Then 1 Else 0 End ) as CKey2
	   ,SUM(CASE When e.[SiteID]=111 Then 1 Else 0 End ) as CKey3
				,e.GamingDate
		FROM Reception.tbl_CustomerIngressi e
		INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
		WHERE s.SiteTypeID = 2  and GamingDate >= @GamingDateFrom AND GamingDate <= @GamingDateTo --count all research done only at sesam
		group by GamingDate,datepart(day,e.entratatimestampLoc),
				datepart(hour,e.entratatimestampLoc) 

) v ON v.GamingDate = c.GamingDate and v.ora = c.ora and v.giorno = c.giorno

order by gamingdate,giorno,ora



RETURN
END
GO
