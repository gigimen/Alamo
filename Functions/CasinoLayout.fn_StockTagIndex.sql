SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [CasinoLayout].[fn_StockTagIndex] 
(
@stockid INT
) 
RETURNS INT
AS
BEGIN
	DECLARE @ret INT,@tag VARCHAR(8),@prog INT
    
    SELECT @tag = Tag
    FROM [CasinoLayout].[Stocks]
	WHERE StockID=@StockID
	
	IF @tag IS NULL
	BEGIN
		SET @ret = 0
		RETURN @ret
	END

	IF LEFT(@tag,2) <> 'UT' AND  LEFT(@tag,2) <> 'SM'
		SET @prog = CAST (RIGHT(@tag,LEN(@tag) -2) AS INT)

	IF LEFT(@tag,2) = 'AR'
		SET @ret = @prog
	ELSE IF LEFT(@tag,2) = 'BJ'
		SET @ret = 10 + @prog
	ELSE IF LEFT(@tag,2) = 'PB'
		SET @ret = 20 + @prog
	ELSE IF LEFT(@tag,2) = 'UT'
		SET @ret = 31
	ELSE IF LEFT(@tag,2) = 'SB'
		SET @ret = 40 + @prog
	ELSE IF LEFT(@tag,2) = 'SM'
		SET @ret = 50
	ELSE IF LEFT(@tag,2) = 'PK'
		SET @ret = 60 + @prog

 	RETURN @ret
END
GO
GRANT EXECUTE ON  [CasinoLayout].[fn_StockTagIndex] TO [SolaLetturaNoDanni]
GO
