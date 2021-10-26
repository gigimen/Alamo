SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[vw_AllAssegniLimiti]
WITH SCHEMABINDING
AS
SELECT     
c.FirstName, 
c.CustomerID, 
c.LastName, 
a.Limite, 
a.Nota, 
c.BirthDate, 
c.Sesso
FROM  Snoopy.tbl_AssegniLimite a 
INNER JOIN  Snoopy.tbl_Customers c ON a.CustomerId = c.CustomerID







GO
