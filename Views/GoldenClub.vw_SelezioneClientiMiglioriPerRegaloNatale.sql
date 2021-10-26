SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [GoldenClub].[vw_SelezioneClientiMiglioriPerRegaloNatale]
AS
select top (1500) * from
(
	SELECT  
		pt.[CustomerID],
		c.LastName,
		c.FirstName,
		m.GoldenClubCardID,
		mt.FDescription												AS MemberType
		,COUNT([TotIngressi])											AS Visite --somma i giorni con visite
		,isnull(SUM([CountEuroIn]),0) + isnull(SUM([CountEuroOut]),0) AS quantiCambiEuro
		,Isnull(SUM([CountRegIn]),0) + isnull(SUM([CountRegOut]),0)	AS quanteRegistrazioni
		,isnull(SUM([CountAss]),0) AS quantiAssegni
		,isnull(SUM([CountCC]),0) AS QuanteCC
	FROM [GoldenClub].[tbl_PlayerTracking] pt
	INNER JOIN Snoopy.tbl_Customers c ON pt.CustomerID = c.CustomerID
	LEFT OUTER JOIN GoldenClub.tbl_Members m ON pt.CustomerID = m.CustomerID
	LEFT OUTER JOIN GoldenClub.tbl_MemberTypes mt ON mt.MemberTypeID = m.MemberTypeID
	WHERE Gamingdate >= '1.6.2017'
	GROUP BY pt.[CustomerID],c.LastName,c.FirstName,m.GoldenClubCardID,mt.FDescription
	HAVING COUNT([TotIngressi]) > 20 --20 visite negli utlimi 6 mesi
	AND 
	(
	SUM([CountEuroIn]) IS NOT NULL 
	OR SUM([CountEuroOut]) IS NOT NULL
	OR SUM([CountRegIn]) IS NULL
	OR SUM([CountRegOut]) IS NOT NULL
	OR SUM([CountAss]) IS NOT NULL
	OR SUM([CountCC]) IS NOT NULL
	)
) a

order by quanteRegistrazioni desc


GO
