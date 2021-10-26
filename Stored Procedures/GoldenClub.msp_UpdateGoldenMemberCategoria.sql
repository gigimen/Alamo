SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[msp_UpdateGoldenMemberCategoria] 
 @xGiorni INT = 180,
 @xOldCust INT = 180
AS
DECLARE @err INT


--DECLARE @xGiorni INT,@xOldCust INT;SET @xGiorni = 56;SET @xOldCust = 180

--caratteristica 3 = frequenza di reg (1=alta,2=media,3=bassa,4=zero)
--caratteristica 4 = valore di reg (1=alta,2=media,3=bassa,4=zero)
/*
SELECT [GoldenClub].[fn_CategoriaFromCriteri] (a.c1,a.c2,a.c3,a.c4)   AS Categoria,a.c1,a.c2,a.c3,a.c4,
a.CustomerID,
a.LastName,
a.FirstName
FROM
(
		
	SELECT	c1.CustomerID,
			c1.LastName,
			c1.FirstName,
			c1.Categoria,
			c23.CustomerID AS c23custID,
			ISNULL(c23.FreqEntrate,4) AS c2,  --4=zero		nessuna entrata in @xGiorni giorni
			CASE 
				WHEN c23.FreqReg >= 0.5 THEN 1
				WHEN c23.FreqReg >= 0.2 THEN 2
				WHEN c23.FreqReg > 0 THEN 3
				ELSE 4
			END AS c3,
			CASE 
				WHEN c23.avgVinto >= 5000 THEN 1		--piu di 5000 vinto di media
				WHEN c23.avgVinto >= 1000 THEN 2		--tra 1000 e 5000 vinto di media
				WHEN c23.avgVinto >= 500 THEN 3			--tra 500 e 1000 vinto di media
				when c23.avgVinto > 0	THEN 4			--meno di 500 vinto di media
				ELSE 5									-- vinto niente
			END AS c4,
			CASE WHEN DATEDIFF(day,[IdentificationGamingDate],GETUTCDATE()) <= @xOldCust THEN 1 ELSE 0 END AS c1

	FROM GoldenClub.vw_AllGoldenMembers c1
	LEFT OUTER join
	(
	--DECLARE @xGiorni INT;SET @xGiorni = 56
		SELECT 
		--metti insieme i giorni con entrate e i giorni con registrazioni
			ISNULL(reg.CustomerID,entr.CustomerID) AS CustomerID,
			--conta i giorni con registrazioni
			COUNT(DISTINCT reg.GamingDate) AS totReg,
			entr.FreqEntrate,
			entr.totEntrate,
			--frequenza di registrazioni = quanti giorni di entrate ha anche regitrazioni
			CAST(ISNULL(COUNT(DISTINCT reg.GamingDate),0) AS FLOAT) / (CASE WHEN entr.totEntrate IS NULL OR entr.totEntrate = 0 THEN 1 ELSE entr.totEntrate end) AS FreqReg,
			--mediamente quanto vince
			ISNULL(SUM(reg.SaldoVinto),0) / (CASE WHEN COUNT(DISTINCT reg.GamingDate) IS NULL OR COUNT(DISTINCT reg.GamingDate) = 0 THEN 1 ELSE COUNT(DISTINCT reg.GamingDate) END) AS avgVinto
		FROM 
		(
			--calcolo del saldo vinto per GamingDate negli ultimi @xGiorni giorni
			--DECLARE @xGiorni INT;SET @xGiorni = 56
			SELECT 
			reg.CustomerID,
			reg.GamingDate,
			SUM(
			CASE 
				WHEN ca.Direction = 'Cashin' THEN -reg.AmountSFr 
				WHEN ca.Direction = 'CashOUt' THEN reg.AmountSFr
				ELSE 0
			END
			) AS SaldoVinto --calcola il saldo vinto per giorno
			FROM Snoopy.Registrations reg
			INNER JOIN Snoopy.IDCauses ca ON ca.IDCauseID = reg.CauseID
			INNER JOIN GoldenClub.Members m ON m.CustomerID = reg.CustomerID
			WHERE GamingDate >= GETDATE() - @xGiorni --solo gli ultimi @xGiorni giorni
			GROUP BY 
			reg.CustomerID,
			reg.GamingDate
			HAVING SUM(
			CASE 
				WHEN ca.Direction = 'Cashin' THEN -reg.AmountSFr 
				WHEN ca.Direction = 'CashOUt' THEN reg.AmountSFr
				ELSE 0
			END
			) <> 0 --escludi i giorni in cui non ha movimento
		) reg
		FULL OUTER JOIN 
		(
			--caratteristica 2 = frequenza (1=alta,2=media,3=bassa,4=0)


			--DECLARE @xGiorni INT;SET @xGiorni = 56
			SELECT e.CustomerID,
			COUNT(DISTINCT e.GamingDate) AS totEntrate,
				CASE 
					WHEN COUNT(DISTINCT e.GamingDate) >=	8 THEN 1 --1=alta		piu di 8 entrate in @xGiorni giorni
					WHEN COUNT(DISTINCT e.GamingDate) >=	2 THEN 2 --2=media		da 2 a 8 entrate in @xGiorni giorni
					WHEN COUNT(DISTINCT e.GamingDate) >	0 THEN 3	 --3=bassa		da 1 a 2 entrate in @xGiorni giorni
					ELSE 4											 --4=zero		nessuna entrata in @xGiorni giorni
				END AS FreqEntrate
			FROM GoldenClub.Ingressi e
			INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
			WHERE e.GamingDate >= GETDATE() - @xGiorni
			AND e.IsUscita = 0
			AND s.SiteTypeID = 2 --only records on sesam entrance
			GROUP BY e.CustomerID

		) entr ON reg.CustomerID = entr.CustomerID
		GROUP BY ISNULL(reg.CustomerID,entr.CustomerID),
			entr.FreqEntrate,
			entr.totEntrate
	) c23 ON c23.CustomerID = c1.CustomerID
) a
--WHERE c23.avgVinto >= 5000 
ORDER BY [GoldenClub].[fn_CategoriaFromCriteri] (a.c1,a.c2,a.c3,a.c4),a.LastName asc

*/


BEGIN TRANSACTION UpdateGoldenMemberCat


UPDATE GoldenClub.tbl_Members
	--evita salti di categoria > di 2 sia in avanti che indietro
--   SET [Categoria] = CASE WHEN ABS(cat.CategoriaIntabella - cat.Categoria) >= 2 THEN cat.CategoriaIntabella ELSE cat.Categoria END
	
	--vogliamo aggiornare la categori ai dati di oggi 11.12.2019
	SET [Categoria] = cat.Categoria 
FROM GoldenClub.tbl_Members m,
(
/*


declare
 @xGiorni INT,
 @xOldCust INT

 set  @xGiorni = 90
 set @xOldCust = 180


--*/
	SELECT [GoldenClub].[fn_CategoriaFromCriteri] (a.c1,a.c2,a.c3,a.c4) AS Categoria,
	a.CustomerID,
	a.LastName,
	a.FirstName,
	a.Categoria AS CategoriaInTabella 
	FROM
	(
		--DECLARE @xGiorni INT,@xOldCust INT;SET @xGiorni = 90; set @xOldCust = 180
		SELECT	c1.CustomerID,
				c1.LastName,
				c1.FirstName,
				c1.Categoria,
				c23.CustomerID AS c23custID,
				ISNULL(c23.FreqEntrate,4)						AS c2,  --Frequenza entrate: 4=zero		nessuna entrata in @xGiorni giorni
				CASE 
					WHEN c23.FreqReg >= 0.5 THEN 1
					WHEN c23.FreqReg >= 0.2 THEN 2
					WHEN c23.FreqReg > 0 OR (c23.avgSaldo>0 AND c23.FreqEntrate IS NULL) THEN 3
					ELSE 4
				END												AS c3,  --
				CASE 
					WHEN c23.avgSaldo >= 5000 THEN 1		--piu di 5000 vinto di media
					WHEN c23.avgSaldo >= 1000 THEN 2		--tra 1000 e 5000 vinto di media
					WHEN c23.avgSaldo >= 500 THEN 3			--tra 500 e 1000 vinto di media
					WHEN c23.avgSaldo > 0	THEN 4			--meno di 500 vinto di media
					ELSE 5									-- vinto niente
				END AS c4,
				CASE WHEN DATEDIFF(DAY,[IdentificationGamingDate],GETUTCDATE()) <= @xOldCust THEN 1 ELSE 0 END AS c1

		FROM GoldenClub.vw_AllGoldenAndDragonMembers c1
		LEFT OUTER JOIN
		(
		--DECLARE @xGiorni INT;SET @xGiorni = 56
			SELECT 
			--metti insieme i giorni con entrate e i giorni con registrazioni
				ISNULL(reg.CustomerID,entr.CustomerID) AS CustomerID,
				--conta i giorni con registrazioni
				COUNT(DISTINCT reg.GamingDate) AS totReg,
				ISNULL(entr.FreqEntrate,3) AS FreqEntrate,
				ISNULL(entr.totEntrate,1) AS totEntrate,
				--frequenza di registrazioni = quanti giorni di entrate ha anche regitrazioni
				CAST(ISNULL(COUNT(DISTINCT reg.GamingDate),0) AS FLOAT) / (CASE WHEN entr.totEntrate IS NULL OR entr.totEntrate = 0 THEN 1 ELSE entr.totEntrate END) AS FreqReg,
				--mediamente quanto vince
				ISNULL(SUM(reg.Saldo),0) / (CASE WHEN COUNT(DISTINCT reg.GamingDate) IS NULL OR COUNT(DISTINCT reg.GamingDate) = 0 THEN 1 ELSE COUNT(DISTINCT reg.GamingDate) END) AS avgSaldo
			FROM 
			(
				--calcolo del saldo vinto per GamingDate negli ultimi @xGiorni giorni
				--DECLARE @xGiorni INT;SET @xGiorni = 56
				SELECT 
				reg.CustomerID,
				reg.GamingDate,
				ABS(SUM(
				CASE 
					WHEN ca.Direction = 'Cashin' THEN -reg.AmountSFr 
					WHEN ca.Direction = 'CashOUt' THEN reg.AmountSFr
					ELSE 0
				END
				)) AS Saldo --calcola il saldo vinto per giorno
				FROM Snoopy.tbl_Registrations reg
				INNER JOIN Snoopy.tbl_IDCauses ca ON ca.IDCauseID = reg.CauseID
				INNER JOIN GoldenClub.tbl_Members m ON m.CustomerID = reg.CustomerID
				WHERE GamingDate >= GETDATE() - @xGiorni --solo gli ultimi @xGiorni giorni
				GROUP BY 
				reg.CustomerID,
				reg.GamingDate
				HAVING SUM(
				CASE 
					WHEN ca.Direction = 'Cashin' THEN -reg.AmountSFr 
					WHEN ca.Direction = 'CashOUt' THEN reg.AmountSFr
					ELSE 0
				END
				) <> 0 --escludi i giorni in cui non ha movimento
			) reg
			FULL OUTER JOIN 
			(
				--caratteristica 2 = frequenza (1=alta,2=media,3=bassa,4=0)


				--DECLARE @xGiorni INT;SET @xGiorni = 90
				SELECT e.CustomerID,
				COUNT(DISTINCT e.GamingDate) AS totEntrate,
					CASE 
						WHEN COUNT(DISTINCT e.GamingDate) >=	@xGiorni / 2 THEN 1 --1=alta		piu di dell metà di @xGiorni giorni
						WHEN COUNT(DISTINCT e.GamingDate) >=	@xGiorni / 3 THEN 2	--2=media		di 1 terzo di @xGiorni giorni
						WHEN COUNT(DISTINCT e.GamingDate) >		0 THEN 3			--3=bassa		da 1 a 2 entrate in @xGiorni giorni
						ELSE 4														--4=zero		nessuna entrata in @xGiorni giorni
					END AS FreqEntrate
				FROM Snoopy.tbl_CustomerIngressi e
				INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
				WHERE e.GamingDate >= GETDATE() - @xGiorni
				AND e.IsUscita = 0
				AND s.SiteTypeID = 2 --only records on sesam entrance
				GROUP BY e.CustomerID

			) entr ON reg.CustomerID = entr.CustomerID
			GROUP BY ISNULL(reg.CustomerID,entr.CustomerID),
				entr.FreqEntrate,
				entr.totEntrate
			
		) c23 ON c23.CustomerID = c1.CustomerID
		--ORDER BY c23.FreqEntrate desc,c1.LastName
	) a
	--ORDER BY 	a.Categoria,a.LastName

) cat
WHERE m.CustomerID = cat.CustomerID



IF (@ERR <> 0) BEGIN	ROLLBACK TRANSACTION UpdateGoldenMemberCat	RETURN @ERR		END

COMMIT TRANSACTION UpdateGoldenMemberCat

RETURN 0
GO
