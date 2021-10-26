SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Accounting].[fn_DropOrario]
(
@GamingDate			DATETIME
)
RETURNS   @ret TABLE(
	[GamingDate]	datetime not null,
	[giorno]		INT not null,
	[ora]			INT not null,
	DropStimato		INT not null
	)
AS
BEGIN

/*
DECLARE @gamingdate DATETIME

SET @gamingdate ='10.24.2020' 

select * from [Accounting].[fn_DropOrario]
(
@GamingDate			
)
*/

/*drop medio orario e giorni settimanali*/

DECLARE @giorno INT,@giornodopo INT
SET @giorno = DATEPART(DAY,@GamingDate)
SET @giornodopo = DATEPART(DAY,DATEADD(DAY,1,@GamingDate))

DECLARE @gg TABLE(
	ix				INT	NOT NULL,
	[GamingDate]	DATETIME NOT NULL,
	[giorno]		INT NOT NULL,
	[ora]			INT NOT NULL,
	PRIMARY KEY CLUSTERED (ix)
	)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (1	,@GamingDate,@giorno,10)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (2	,@GamingDate,@giorno,11)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (3	,@GamingDate,@giorno,12)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (4	,@GamingDate,@giorno,13)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (5	,@GamingDate,@giorno,14)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (6	,@GamingDate,@giorno,15)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (7	,@GamingDate,@giorno,16)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (8	,@GamingDate,@giorno,17)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (9	,@GamingDate,@giorno,18)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (10	,@GamingDate,@giorno,19)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (11	,@GamingDate,@giorno,20)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (12	,@GamingDate,@giorno,21)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (13	,@GamingDate,@giorno,22)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (14	,@GamingDate,@giorno,23)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (15	,@GamingDate,@giornodopo,0)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (16	,@GamingDate,@giornodopo,1)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (17	,@GamingDate,@giornodopo,2)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (18	,@GamingDate,@giornodopo,3)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (19	,@GamingDate,@giornodopo,4)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (20	,@GamingDate,@giornodopo,5)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (21	,@GamingDate,@giornodopo,6)
INSERT INTO @gg (ix,[GamingDate],[giorno],[ora]) VALUES (22 ,@GamingDate,@giornodopo,7)


--select * from @gg
INSERT INTO @ret
(
    GamingDate,
    giorno,
    ora,
    DropStimato
)
SELECT a.GamingDate,a.giorno,a.ora,
ISNULL(b.DropStimato,0) AS DropStimato
FROM @gg a
LEFT OUTER JOIN 
(
	SELECT  
		DATEPART(day,i.StateTimeLoc) AS giorno,
		DATEPART(hour,i.StateTimeLoc) AS ora,
		Sum(DropIncr) as DropStimato,
		i.GamingDate
	
	FROM 
	(
		SELECT GamingDate,StateTimeLoc,SUM(a.Value - a.PrevValue) AS DropIncr
		FROM
		(
		SELECT LifeCycleID,StateTimeLoc,Value,GamingDate, 
		LAG(Value,1,0) OVER(PARTITION BY LifeCycleID ORDER BY StateTimeLoc ASC) AS PrevValue

		FROM [Accounting].[vw_AllProgress] i
		WHERE GamingDate >= @gamingdate AND GamingDate < DATEADD(DAY,1,@gamingdate)
		AND denoid = 11

		) a		
		GROUP BY GamingDate,StateTimeLoc
		
	) i
	group BY 
	DATEPART(day,i.StateTimeLoc) ,
	DATEPART(hour,i.StateTimeLoc),
	i.GamingDate
) b ON b.GamingDate =a.GamingDate AND b.ora = a.ora AND b.giorno = a.giorno
ORDER BY a.ix
RETURN
END

GO
