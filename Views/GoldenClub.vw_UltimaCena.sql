SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [GoldenClub].[vw_UltimaCena]
WITH SCHEMABINDING
AS
SELECT     
c.CustomerID, 
c.LastName, 
c.FirstName,
g.GamingDate,
GeneralPurpose.fn_UTCToLocal(1, g.InsertTimeStampUTC) AS OraCena, 
tc.FDescription as TipoCena,
tc.TipoCenaID,
case 
when g.GamingDate = [GeneralPurpose].[fn_GetGamingLocalDate2] 
(
GETDATE(),0,4 --cassa stock type
) then 1
else 0
end as IsToday
FROM GoldenClub.tbl_PartecipazioneCena AS g 
inner join ( select MAX(CenaID) as cenaID,CustomerID from GoldenClub.tbl_PartecipazioneCena group by CustomerID) as u on g.CenaID = u.cenaID
INNER JOIN GoldenClub.tbl_Members AS gc ON gc.CustomerID = g.CustomerID 
INNER JOIN Snoopy.tbl_Customers AS c ON c.CustomerID = g.CustomerID
INNER JOIN GoldenClub.tbl_TipoCene tc on tc.TipoCenaID = g.TipoCenaID
GO
