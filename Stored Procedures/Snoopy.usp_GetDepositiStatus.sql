SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Snoopy].[usp_GetDepositiStatus] 
@lfid int
AS
declare @closedate datetime

select @closedate = CloseTime
from [Accounting].[vw_AllStockLifeCycles] 
where LifeCycleID = @lfid


--lfid is not valid or not yet closed just return current situation
if @closedate is null
begin
	SELECT [DepositoID]
		,[DepOnLFID]
		,[DepOnGamingdate]
		,[DepOnTransID]
		,[CustomerTransactionTime]
		,[DepOnTransTime]
		,[LastName]
		,[FirstName]
		,[Sesso]
		,[CustomerID]
		,[BirthDate]
		,[CustInsertDate]
		,[NrTelefono]
		,[Causale]
		,[CategoriaRischio]
		,[Importo]
		,[DepOffLFID]
		,[DepOffGamingdate]
		,[DepOffID]
		,[DepOffTransTime]
		,[IdentificationID]
		,[IdentificationGamingDate]
		,[ColloquioGamingDate]
		,[FormIVtimeLoc]
		,[RegID]
		,[ExpirationDate]
		,[IDDocumentID]
		,[DocInfo]
		,[Citizenship]
		,[IsGoldenClubMember]
		,[GoldenClubCardID]
		,[EMailAddress]
		,StartUseMobileTimeStamp
		,[SMSNumber]
		,[GoldenIDDocumentID]
		,[SMCheckTime]
		,[CheckedBy]
	FROM [Snoopy].[vw_AllDepositi]
	where DepOffTransTime is null
end
else
begin
	print @closedate
	
	SELECT [DepositoID]
		,[DepOnLFID]
		,[DepOnGamingdate]
		,[DepOnTransID]
		,[CustomerTransactionTime]
		,[DepOnTransTime]
		,[LastName]
		,[FirstName]
		,[Sesso]
		,[CustomerID]
		,[BirthDate]
		,[CustInsertDate]
		,[NrTelefono]
		,[Causale]
		,[CategoriaRischio]
		,[Importo]
		,[DepOffLFID]
		,[DepOffGamingdate]
		,[DepOffID]
		,[DepOffTransTime]
		,[IdentificationID]
		,[IdentificationGamingDate]
		,[ColloquioGamingDate]
		,[FormIVtimeLoc]
		,[RegID]
		,[ExpirationDate]
		,[IDDocumentID]
		,[DocInfo]
		,[Citizenship]
		,[IsGoldenClubMember]
		,[GoldenClubCardID]
		,[EMailAddress]
		,StartUseMobileTimeStamp
		,[SMSNumber]
		,[GoldenIDDocumentID]
		,[SMCheckTime]
		,[CheckedBy]
	FROM [Snoopy].[vw_AllDepositi]
	where DepOnTransTime <= @CloseDate 
	and (
		DepOffTransTime is null --still have to be prelevata 
		or
		DepOffTransTime >= @CloseDate --prelevate today
	)
end
GO
