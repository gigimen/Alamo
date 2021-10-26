SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Snoopy].[fn_VisiteOrarie]
(
@GamingDate			DATETIME
)
RETURNS   @ret TABLE(
	ix				INT	not null,
	[GamingDate]	datetime not null,
	[giorno]		INT not null,
	[ora]			INT not null,
	controlli		INT not null,
	VisiteAdmiral	INT not null,
	VisiteTotali	INT not null,
	EntrateTotali	INT not null,
	Uscite			INT not null,
	Saldo			INT not null,
	PRIMARY KEY CLUSTERED (ix)
	)

AS
BEGIN
/*


declare @GamingDate			DATETIME
set @GamingDate = '6.9.2020'

select * from [Snoopy].[fn_VisiteOrarie] (@GamingDate)
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
insert into @gg (ix,[GamingDate],[giorno],[ora]) values (22,@GamingDate,@giornodopo,7)


--select * from @gg

INSERT INTO  @ret
(
	[ix]			,
	[GamingDate]	,
	[giorno]		,
	[ora]			,
	controlli		,
	VisiteAdmiral	,
	VisiteTotali	,
	EntrateTotali	,
	Uscite			,
	Saldo			
)
SELECT 
g.ix,
g.GamingDate,
g.giorno,
g.ora,
ISNULL(c.Controlli,0)													as controlli,
ISNULL(v.Visite,0)														as VisiteAdmiral,
ISNULL(c.Controlli,0) + ISNULL(v.Visite,0)								as VisiteTotali,
ISNULL(c.Controlli,0) + ISNULL(v.Entrate,0)								as EntrateTotali,
ISNULL(u.numUscite,0)													as Uscite,
ISNULL(c.Controlli,0) + ISNULL(v.Entrate,0) - ISNULL(u.numUscite,0)		as Saldo


FROM @gg g
LEFT OUTER JOIN
(
	SELECT  
		datepart(day,i.entratatimestampLoc) as giorno,
		datepart(hour,i.entratatimestampLoc) as ora,
		count(*) as Controlli,
		i.GamingDate
	FROM Snoopy.tbl_FasceEtaRegistrations i
	INNER JOIN [Snoopy].[tbl_VetoControls] c ON c.PK_ControllID = i.[FK_ControlID]
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	group by i.GamingDate,datepart(hour,i.entratatimestampLoc),datepart(day,i.entratatimestampLoc)

) c on c.GamingDate = g.GamingDate and c.giorno = g.giorno and c.ora = g.ora
LEFT OUTER JOIN 
(
	SELECT  
		p.giorno,
		p.ora,
		count(distinct p.CustomerID)	as Visite,
		sum(p.numIngressi)				as Entrate,
		p.GamingDate
	from
	(

		SELECT  CustomerID,
				count(*)								as numIngressi,
				datepart(day,e.entratatimestampLoc)		as giorno,
				datepart(hour,e.entratatimestampLoc)	as ora,
				e.GamingDate
		FROM Snoopy.tbl_CustomerIngressi e
		INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
		WHERE s.SiteTypeID = 2  --count all research done only at sesam
		group by CustomerID,GamingDate,datepart(day,e.entratatimestampLoc),
				datepart(hour,e.entratatimestampLoc)

	) p
	group by p.GamingDate,p.giorno,p.ora
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
