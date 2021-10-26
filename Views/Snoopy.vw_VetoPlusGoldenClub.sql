SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Snoopy].[vw_VetoPlusGoldenClub]
AS
SELECT     
	CAST(ISNULL(s.CustomerID,c.CustomerID) AS INT) AS CustomerID,
	ISNULL(s.LastName, c.LastName) AS LastName, 
	ISNULL(s.FirstName, c.FirstName) AS FirstName, 
	ISNULL(s.Birthday, c.BirthDate ) AS birthday 
			,s.[Address]
			,s.[Nationality]
			,s.[Country]
			,s.[Zip]
			,s.[City]
			,s.[CreateDate]
			,s.[Editor]
			,s.[Dossier]
			,s.[Remarks]
			,s.[BarrierStart]
			,s.[BarrierEnd]
			,s.[IsMendrisio]
			,s.[CasinoName]
			,s.[Barrier]
			,s.[BarrierLevel]
			,s.[BarrierReasonNumber]
			,s.ArtDescription
			,s.[BarriedBy]
			,s.[MaxEntries]
			,s.[Deleted]
			,s.[Timestamp]
 		,c.GoldenClubCardID
		,c.CancelDate
		,c.MemberTypeID
		,c.CustomerID						AS AlamoCustomerID
		,c.GoldenParams
	FROM --[Snoopy].[tbl_SesamExclusions] AS s 
(
		 SELECT 300000 + ROW_NUMBER() OVER (ORDER BY [BarrierID]) AS CustomerID
			  ,[FirstName]
			  ,[LastName]
			  ,[Birthday]
			  ,[Address]
			  ,[Nationality]
			  ,[Country]
			  ,[Zip]
			  ,[City]
			  ,[CreateDate]
			  ,[Editor]
			  ,[Dossier]
			  ,[Remarks]
			  ,[BarrierStart]
			  ,[BarrierEnd]
			  ,[IsMendrisio]
			  ,[CasinoName]
			  ,[Barrier]
			  ,[BarrierLevel]
			  ,[BarrierReasonNumber]
			  ,ArtDescription
			  ,[BarriedBy]
			  ,[MaxEntries]
			  ,[Deleted]
			  ,ISNULL([ModifiedTS],[Timestamp]) AS [Timestamp]
		FROM 
		[Veto].[veto].[vw_VetoExclusions]

)
AS s 	/*FULL OUTER JOIN GoldenClub.vw_AlamoGoldenClub AS g 
	ON LEFT(s.FirstName, 5) = LEFT(g.FirstName, 5) 
	AND LEFT(s.LastName, 5) LIKE '%' + LEFT(g.LastName, 5) + '%' 
	AND g.BirthDate = s.Birthday
	*/
	FULL OUTER JOIN 
	--golden club information
	(
		SELECT cu.CustomerID,LastName,FirstName,BirthDate 
			,m.GoldenClubCardID
			,[GeneralPurpose].[fn_UTCToLocal](1,can.CancelDate) AS CancelDate
			,m.MemberTypeID
			,m.GoldenParams
		FROM Snoopy.tbl_Customers cu
		LEFT OUTER JOIN GoldenClub.tbl_Members m ON m.CustomerID = cu.CustomerID
		LEFT OUTER JOIN GoldenClub.tbl_Cards ca ON ca.CustomerID = m.CustomerID AND ca.CancelID IS NULL
		LEFT OUTER JOIN FloorActivity.tbl_Cancellations can ON can.CancelID = m.CancelID
		WHERE cu.CustCancelID IS NULL --customer not flagged cancelled in database
	)
	AS c 
	ON 
	--match on the BirthDate
	c.BirthDate = s.Birthday
	AND --match on the LastName
	(
		REPLACE(s.LastName,'''','´') LIKE '%' + LEFT(c.LastName, 4) + '%' OR
		c.LastName LIKE '%' + LEFT(REPLACE(s.LastName,'''','´'), 4) + '%' 
	)
	AND --match on the FirstName
	(
	s.FirstName LIKE '%' + LEFT(c.FirstName, 4) + '%'
	OR c.FirstName LIKE '%' + LEFT(s.FirstName, 4) + '%' 
	)
	WHERE c.CustomerID IS NULL OR c.CustomerID > 1
GO
