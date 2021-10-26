SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Snoopy].[fn_VisiteOrarieByCKEY]
(
	@GamingDate			DATETIME
)
RETURNS   @ret TABLE(
	ix				INT	not null,
	[GamingDate]	datetime not null,
	[giorno]		INT not null,
	[ora]			INT not null,
	CKEY1			INT,
	CKEY2			INT,
	CKEY3           INT,
	ENTRATE			INT,
	USCITE			INT,
	SALDO			INT,
	PRIMARY KEY CLUSTERED (ix)
	)

AS
BEGIN
/*


declare @GamingDate			DATETIME
set @GamingDate = '11.4.2020'

select *,Sum(Saldo) over(order by ix) as Presenze from [Snoopy].[fn_VisiteOrarieByCKEY] (@GamingDate)
--*/

declare @giorno int,@giornodopo int
set @giorno = datepart(day,@GamingDate)
set @giornodopo = datepart(day,dateadd(day,1,@GamingDate))

declare @gg TABLE(
	ix				INT	not null,
	[GamingDate]	datetime not null,
	[giorno]		INT not null,
	[ora]			INT not null,
	PRIMARY KEY CLUSTERED (ix)
	)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (1	,@GamingDate,@giorno,10)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (2	,@GamingDate,@giorno,11)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (3	,@GamingDate,@giorno,12)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (4	,@GamingDate,@giorno,13)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (5	,@GamingDate,@giorno,14)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (6	,@GamingDate,@giorno,15)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (7	,@GamingDate,@giorno,16)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (8	,@GamingDate,@giorno,17)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (9	,@GamingDate,@giorno,18)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (10	,@GamingDate,@giorno,19)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (11	,@GamingDate,@giorno,20)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (12	,@GamingDate,@giorno,21)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (13	,@GamingDate,@giorno,22)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (14	,@GamingDate,@giorno,23)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (15	,@GamingDate,@giornodopo,0)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (16	,@GamingDate,@giornodopo,1)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (17	,@GamingDate,@giornodopo,2)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (18	,@GamingDate,@giornodopo,3)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (19	,@GamingDate,@giornodopo,4)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (20	,@GamingDate,@giornodopo,5)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (21	,@GamingDate,@giornodopo,6)
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (22 ,@GamingDate,@giornodopo,7)


--select * from @gg

INSERT INTO  @ret
(
	[ix]			,
	[GamingDate]	,
	[giorno]		,
	[ora]			,
	CKEY1,
	CKEY2,
	CKEY3,
	ENTRATE			,
	USCITE			,
	SALDO			
)

SELECT 
g.ix,
g.GamingDate,
g.giorno,
g.ora,
ISNULL(c.CKey1,0) + ISNULL(v.CKey1,0) as CKey1,
ISNULL(c.CKey2,0) + ISNULL(v.CKey2,0) as CKey2,
ISNULL(c.CKey3,0) + ISNULL(v.CKey3,0) as CKey3,
ISNULL(c.CKey1,0) + ISNULL(v.CKey1,0) +
ISNULL(c.CKey2,0) + ISNULL(v.CKey2,0) +
ISNULL(c.CKey3,0) + ISNULL(v.CKey3,0) as Entrate,
ISNULL(u.numUscite,0)				  AS Uscite,
ISNULL(c.CKey1,0) + ISNULL(v.CKey1,0) +
ISNULL(c.CKey2,0) + ISNULL(v.CKey2,0) +
ISNULL(c.CKey3,0) + ISNULL(v.CKey3,0)  - ISNULL(u.numUscite,0)		as Saldo
FROM @gg g
LEFT OUTER JOIN
(
	SELECT  
		datepart(day,i.entratatimestampLoc) as giorno
	   ,datepart(hour,i.entratatimestampLoc) as ora
	   ,i.GamingDate
	   ,SUM(CASE When c.[SiteID]=49 Then 1 Else 0 End ) as CKey1  
	   ,SUM(CASE When c.[SiteID]=50 Then 1 Else 0 End ) as CKey2
	   ,SUM(CASE When c.[SiteID]=111 Then 1 Else 0 End ) as CKey3

	FROM Snoopy.tbl_FasceEtaRegistrations i
	INNER JOIN [Snoopy].[tbl_VetoControls] c ON c.PK_ControllID = i.[FK_ControlID]
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2 --and c.GamingDate >= '10.01.2020' AND c.GamingDate <= '10.28.2020' --count only sesam entrances
	group by i.GamingDate,datepart(hour,i.entratatimestampLoc),datepart(day,i.entratatimestampLoc)

) c on c.GamingDate = g.GamingDate and c.giorno = g.giorno and c.ora = g.ora
left OUTER JOIN 
(

		SELECT  datepart(day,e.entratatimestampLoc)		as giorno,
				datepart(hour,e.entratatimestampLoc)	as ora
	   ,SUM(CASE When e.[SiteID]=49 Then 1 Else 0 End ) as CKey1  
	   ,SUM(CASE When e.[SiteID]=50 Then 1 Else 0 End ) as CKey2
	   ,SUM(CASE When e.[SiteID]=111 Then 1 Else 0 End ) as CKey3
				,e.GamingDate
		FROM Snoopy.tbl_CustomerIngressi e
		INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
		WHERE s.SiteTypeID = 2  --and GamingDate >= '10.01.2020' AND GamingDate <= '10.28.2020' --count all research done only at sesam
		group by GamingDate,datepart(day,e.entratatimestampLoc),
				datepart(hour,e.entratatimestampLoc) 

) v ON v.GamingDate = g.GamingDate and v.ora = g.ora and v.giorno = g.giorno
left outer join
(
		SELECT  sum(Increment)							as numUscite,
				datepart(day,[TimestampLoc])			as giorno,
				datepart(hour,[TimestampLoc])			as ora,
				GamingDate
		FROM Snoopy.tbl_Uscite 
		group by GamingDate,
				datepart(day,[TimestampLoc]),
				datepart(hour,[TimestampLoc])

) u ON u.GamingDate = g.GamingDate and u.ora = g.ora and u.giorno = g.giorno

order by g.ix


RETURN
END
GO
