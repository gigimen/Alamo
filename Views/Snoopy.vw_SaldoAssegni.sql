SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[vw_SaldoAssegni]
WITH SCHEMABINDING
AS
SELECT     
l.CustomerID, 
c.LastName, 
c.FirstName, 
c.BirthDate, 
l.Nota, 
l.Limite,
u.ImportoEuro,
case
when  u.[ImportoEuro] IS null 
then l.[Limite] 
else l.[Limite] - u.[ImportoEuro]
end AS delta

FROM Snoopy.tbl_AssegniLimite l
INNER JOIN   Snoopy.tbl_Customers c ON l.CustomerID = c.CustomerID 
LEFT OUTER JOIN  
(
SELECT     CustomerID, SUM(Importo) AS ImportoEuro
FROM       Snoopy.vw_AllAssegni
WHERE     (RedemptionTime IS NULL) AND (CentaxCode = 'GU') AND DATEDIFF(
	day,
	GamingDate,
	[GeneralPurpose].fn_GetGamingLocalDate2(
		GetUTCDate(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GetUTCDate(),GetDate()),
		7 --Cassa Centrale StockTypeID 
		)) <= 7 --count the last 7 gamingdates
GROUP BY CustomerID
) u ON l.CustomerID = u.CustomerID
GO
