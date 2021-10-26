SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Marketing].[fn_GetBuoniCustomerSummary] 
(
@CustID			INT,
@breveterm		INT,
@lungoterm		INT,
@withImage		INT
)

---

/*
select * from [Marketing].[fn_GetBuoniCustomerSummary] (56059,30,365)

--*/
RETURNS   @ret TABLE(
	Comment					VARCHAR(max),
	VisiteBreveTerm			INT,
	VisiteLungoTerm			INT,
	BuoniCenaBreveTerm		INT,
	BuoniCenaLungoTerm		INT,
	PastaDrinkBreveTerm		INT,
	PastaDrinkLungoTerm		INT,
	MacDonaldBreveTerm		INT,
	MacDonaldLungoTerm		INT,
	LuckyBreveTerm			INT,
	LuckyLungoTerm			INT,
	ImageBin				IMAGE
) 
AS
BEGIN

if @withImage = 1
	insert into @ret
	(
		Comment					,
		VisiteBreveTerm			,
		VisiteLungoTerm			,
		BuoniCenaBreveTerm		,
		BuoniCenaLungoTerm		,
		PastaDrinkBreveTerm		,
		PastaDrinkLungoTerm		,
		MacDonaldBreveTerm		,
		MacDonaldLungoTerm		,
		LuckyBreveTerm			,
		LuckyLungoTerm			,
		ImageBin				
	) 
	SELECT 
		c.Comment,
		ISNULL(vBreveTerm.giorni,0)	AS VisiteBreveTerm	,
		ISNULL(vLungoTerm.giorni,0)	AS VisiteLungoTerm,
		ISNULL(bBreveTerm.buoni,0)	AS BuoniCenaBreveTerm	,
		ISNULL(bLungoTerm.buoni,0)	AS BuoniCenaLungoTerm	,
		ISNULL(pBreveTerm.buoni,0)	AS PastaDrinkBreveTerm	,
		ISNULL(pLungoTerm.buoni,0)	AS PastaDrinkLungoTerm,
		ISNULL(mBreveTerm.buoni,0)	AS MacDonaldBreveTerm	,
		ISNULL(mLungoTerm.buoni,0)	AS MacDonaldLungoTerm,
		ISNULL(lBreveTerm.buoni,0)	AS LuckyBreveTerm	,
		ISNULL(lLungoTerm.buoni,0)	AS LuckyLungoTerm,
		a.ImageBin 
		FROM Snoopy.tbl_Customers  c 
		LEFT OUTER JOIN 
		(
			SELECT top 1 ImageBin,CustomerID 
			from  [Giotto].[Snoopy].[ImmaginiDocumenti] i
			left outer join  Snoopy.tbl_IDDocuments  d on d.IDDocumentID=i.IDDocumentID
			where d.CustomerID = @CustID and i.PageNr = 1
			order by i.InsertTimeStampUTC DESC
		) a ON a.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(DISTINCT GamingDate) AS giorni,Customerid
				FROM  Snoopy.tbl_CustomerIngressi  i
				WHERE CustomerID = @CustID AND i.GamingDate >= GETDATE() - @breveterm
				GROUP BY CustomerID
		) vBreveTerm ON vBreveTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
			SELECT COUNT(DISTINCT gamingdate) AS giorni,Customerid
			FROM  Snoopy.tbl_CustomerIngressi  i
			WHERE CustomerID = @CustID AND i.GamingDate >= GETDATE() - @lungoterm
			GROUP BY Customerid
		) vLungoTerm ON vLungoTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 19 and PremioID = 50
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
			GROUP BY Customerid
		) bBreveTerm ON bBreveTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 19 and PremioID = 50
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
			GROUP BY Customerid
		) bLungoTerm ON bLungoTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 19 and PremioID = 54
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
			GROUP BY Customerid
		) pBreveTerm ON pBreveTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 19 and PremioID = 54
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
			GROUP BY Customerid
		) pLungoTerm ON pLungoTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 26 and PremioID = 87
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
			GROUP BY Customerid
		) mBreveTerm ON mBreveTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 26 and PremioID = 87
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
			GROUP BY Customerid
		) mLungoTerm ON mLungoTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 27 and PremioID = 88
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
			GROUP BY Customerid
		) lBreveTerm ON lBreveTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 27 and PremioID = 88
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
			GROUP BY Customerid
		) lLungoTerm ON lLungoTerm.CustomerID = c.CustomerID		
		WHERE c.Customerid = @CustID
	else
		insert into @ret
		(
			Comment					,
			VisiteBreveTerm			,
			VisiteLungoTerm			,
			BuoniCenaBreveTerm		,
			BuoniCenaLungoTerm		,
			PastaDrinkBreveTerm		,
			PastaDrinkLungoTerm		,
			MacDonaldBreveTerm		,
			MacDonaldLungoTerm		,
			LuckyBreveTerm			,
			LuckyLungoTerm			,
			ImageBin				
		) 
		SELECT 
			c.Comment,
			ISNULL(vBreveTerm.giorni,0)	AS VisiteBreveTerm	,
			ISNULL(vLungoTerm.giorni,0)	AS VisiteLungoTerm,
			ISNULL(bBreveTerm.buoni,0)	AS BuoniCenaBreveTerm	,
			ISNULL(bLungoTerm.buoni,0)	AS BuoniCenaLungoTerm	,
			ISNULL(pBreveTerm.buoni,0)	AS PastaDrinkBreveTerm	,
			ISNULL(pLungoTerm.buoni,0)	AS PastaDrinkLungoTerm,
			ISNULL(mBreveTerm.buoni,0)	AS MacDonaldBreveTerm	,
			ISNULL(mLungoTerm.buoni,0)	AS MacDonaldLungoTerm,
			ISNULL(lBreveTerm.buoni,0)	AS LuckyBreveTerm	,
			ISNULL(lLungoTerm.buoni,0)	AS LuckyLungoTerm,
			NULL 
			FROM Snoopy.tbl_Customers  c 
			left OUTER JOIN 
			(
					SELECT COUNT(DISTINCT GamingDate) AS giorni,Customerid
					FROM  Snoopy.tbl_CustomerIngressi  i
					WHERE CustomerID = @CustID AND i.GamingDate >= GETDATE() - @breveterm
					GROUP BY CustomerID
			) vBreveTerm ON vBreveTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
				SELECT COUNT(DISTINCT gamingdate) AS giorni,Customerid
				FROM  Snoopy.tbl_CustomerIngressi  i
				WHERE CustomerID = @CustID AND i.GamingDate >= GETDATE() - @lungoterm
				GROUP BY Customerid
			) vLungoTerm ON vLungoTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
					SELECT COUNT(*) AS buoni,Customerid
					FROM [Marketing].[tbl_AssegnazionePremi] a
					INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
					WHERE o.PromotionID = 19 and PremioID = 50
					AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
				GROUP BY Customerid
			) bBreveTerm ON bBreveTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
					SELECT COUNT(*) AS buoni,Customerid
					FROM [Marketing].[tbl_AssegnazionePremi] a
					INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
					WHERE o.PromotionID = 19 and PremioID = 50
					AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
				GROUP BY Customerid
			) bLungoTerm ON bLungoTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
					SELECT COUNT(*) AS buoni,Customerid
					FROM [Marketing].[tbl_AssegnazionePremi] a
					INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
					WHERE o.PromotionID = 19 and PremioID = 54
					AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
				GROUP BY Customerid
			) pBreveTerm ON pBreveTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
					SELECT COUNT(*) AS buoni,Customerid
					FROM [Marketing].[tbl_AssegnazionePremi] a
					INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
					WHERE o.PromotionID = 19 and PremioID = 54
					AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
				GROUP BY Customerid
			) pLungoTerm ON pLungoTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
					SELECT COUNT(*) AS buoni,Customerid
					FROM [Marketing].[tbl_AssegnazionePremi] a
					INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
					WHERE o.PromotionID = 26 and PremioID = 87
					AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
				GROUP BY Customerid
			) mBreveTerm ON mBreveTerm.CustomerID = c.CustomerID
			left OUTER JOIN 
			(
					SELECT COUNT(*) AS buoni,Customerid
					FROM [Marketing].[tbl_AssegnazionePremi] a
					INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
					WHERE o.PromotionID = 26 and PremioID = 87
					AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
				GROUP BY Customerid
			) mLungoTerm ON mLungoTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 27 and PremioID = 88
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @breveterm
			GROUP BY Customerid
		) lBreveTerm ON lBreveTerm.CustomerID = c.CustomerID
		left OUTER JOIN 
		(
				SELECT COUNT(*) AS buoni,Customerid
				FROM [Marketing].[tbl_AssegnazionePremi] a
				INNER JOIN [Marketing].[tbl_OffertaPremi] o ON o.OffertaPremioID = a.OffertaPremioID
				WHERE o.PromotionID = 27 and PremioID = 88
				AND a.CustomerID = @CustID AND a.[InsertTimeStampUTC] >= GETDATE() - @lungoterm
			GROUP BY Customerid
		) lLungoTerm ON lLungoTerm.CustomerID = c.CustomerID		
		WHERE c.Customerid = @CustID

RETURN

END
GO
