SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_BSETableOrarioDalAl]
(
@from			DATETIME,
@to				DATETIME
)
RETURNS   @ret TABLE(
	[GamingDate]	DATETIME NOT NULL,
	[giorno]		INT NOT NULL,
	[ora]			INT NOT NULL,
	BSEIncr			INT NOT NULL
	)
AS
BEGIN



DECLARE @gaming DATETIME


	SET @gaming = @from

	WHILE @gaming <= @to
	BEGIN

		INSERT INTO @ret
		(
		    GamingDate,
			giorno,
		    ora,
		    BSEIncr
		)
		SELECT GamingDate,giorno,ora,BSEIncr FROM [Accounting].[fn_BSETableOrario] (@gaming)
			--WHERE DATEPART(WEEKDAY,GamingDate ) IN(1,2,3,4,5) AND ora in 5

		SET @gaming = DATEADD(DAY,1,@gaming)
	END

	RETURN
	END
GO
