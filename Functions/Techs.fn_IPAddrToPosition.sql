SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Techs].[fn_IPAddrToPosition] (
  @ipAddress INT
) RETURNS NVARCHAR(21) AS BEGIN
  -- {version:"1", changed:"2015-02-02"}
  DECLARE @o2 INT, @o3 INT, @o4 INT;

  SET @ipAddress = @ipAddress % 16777216;
  SET @o2 = @ipAddress / 65536;
  SET @ipAddress = @ipAddress % 65536;
  SET @o3 = @ipAddress / 256;
  SET @ipAddress = @ipAddress % 256;
  SET @o4 = @ipAddress;

  RETURN /*RIGHT('000' + CONVERT(NVARCHAR(3), @o2), 3)
    + '-' +*/ RIGHT('000' + CONVERT(NVARCHAR(3), @o3), 3)
    + '-' + RIGHT('000' + CONVERT(NVARCHAR(3), @o4), 3);
/*
  RETURN CONVERT(NVARCHAR(3), @o2)
    + '.' + CONVERT(NVARCHAR(3), @o3)
    + '.' + CONVERT(NVARCHAR(3), @o4);
	*/
END


GO
