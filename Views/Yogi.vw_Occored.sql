SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Yogi].[vw_Occored] AS
SELECT
	 o.Id
	,c.CustomerID
	,c.LastName 
	,c.FirstName
	,c.BirthDate
	,a.Description AS TipoAmmonimento
	,o.GamingDate
	,u.LastName + ' ' + u.FirstName AS InseritoDa
	,o.Descrizione
	,o.osservazione
FROM [Yogi].[tbl_Occurred] o
INNER JOIN [Snoopy].[tbl_Customers] c ON 
o.[FK_CustomerID] = c.CustomerID 

INNER JOIN [Yogi].[tbl_Actions] a ON
o.ActionID = a.Id

INNER JOIN [CasinoLayout].[Users] AS u
ON o.FK_UserID = u.UserID

GO
