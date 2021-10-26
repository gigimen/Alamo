SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Snoopy].[usp_GetCustomerFoto] 
@customerID int
as
/*
declare @customerID int
set @customerID = 20967
*/
select top 1 ImageBin 
	from [Giotto].Snoopy.ImmaginiDocumenti i
inner join Snoopy.vw_AllCustomerIDDocuments d	on i.IDDocumentID = d.IDDocumentID 
where d.CustomerID = @customerID and PageNr = 1
order by d.InsertGamingDate desc
GO
