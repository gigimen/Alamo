SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [CasinoLayout].[vw_AllStockStatus] 
WITH SCHEMABINDING
AS

SELECT st.Tag,
	st.FName,
	st.FDescription,
	st.StockTypeID,
	st.StockID,
	st.MinBet,
	st.FromGamingDate,
	st.TillGamingDate,
	CASE WHEN GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				st.StockTypeID) >= st.FromGamingDate AND 
				(
				GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				st.StockTypeID) <= st.TillGamingDate OR st.TillGamingDate IS null) THEN 1
	ELSE 0 
	END AS IsActive

from CasinoLayout.Stocks st
GO
