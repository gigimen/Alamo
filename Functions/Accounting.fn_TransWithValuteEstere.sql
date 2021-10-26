SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Accounting].[fn_TransWithValuteEstere] (@nTransID int)  
RETURNS INT
WITH SCHEMABINDING
AS  
BEGIN 
--get the last known lifecycle of this stock
declare @valEsPresent int
set @valEsPresent = 0

if exists 
	(
		select TransactionID from Accounting.vw_AllTransactionDenominations
		where TransactionID = @nTransID 
		and ValueTypeID IN	(8,9,23,24,25,26,27,28)
			/*( ValueTypeName = 'Dollari'
			or ValueTypeName = 'Sterline'
			or ValueTypeName = 'Dollari canadesi'
			or ValueTypeName = 'Dollari australiani'
			or ValueTypeName = 'Corone norvegesi'
			or ValueTypeName = 'Corone danesi'
			or ValueTypeName = 'Corone svedesi'
			or ValueTypeName = 'Yen giapponesi'
			)*/
	)
	set @valEsPresent = 1
return @valEsPresent
END



GO
