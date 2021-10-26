SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  UserDefinedFunction [GeneralPurpose].[fn_GetGamingLocalDate2]    Script Date: 15.09.2014 15:17:28 ******/
CREATE procedure [GeneralPurpose].[usp_BroadcastChangeOfGamingDate]
@c  INT output

AS  

	  /*
	  
	  select   
	  '<ALAMO version=''1''><MESS type=''ChangeOfGamingDate'' StockTypeID=''' + 
	  cast (st.[StockTypeID] AS VARCHAR(16)) + ''' GamingDate=''' +
	  [GeneralPurpose].[fn_CastDateForAdoRead] (GeneralPurpose.fn_GetGamingLocalDate2(
					GetUTCDate(),
					--pass current hour difference between local and utc 
					DATEDIFF (hh , GetUTCDate(),GetDate()),
					st.[StockTypeID]
					))+ '''/></ALAMO>'
		,st.[StockTypeID],
		CAST(REPLACE(st.[ChangeOfGamingDate],':00','') AS INT),
		DATEPART(HOUR,GETDATE()) as ora,
		CAST(cp.VarValue as int) AS port,
		ca.VarValue AS addr
	FROM [CasinoLayout].[StockTypes] st ,[GeneralPurpose].[ConfigParams] cp,[GeneralPurpose].[ConfigParams] ca
		WHERE cp.VarName = 'AlamoMessagesPort'
			and ca.VarName = 'AlamoMessagesNetwork'
		and  CAST(REPLACE([ChangeOfGamingDate],':00','') AS INT) =	DATEPART(HOUR,GETDATE())
		
		*/
	SELECT 
			[GeneralPurpose].[asm_Broadcast] 
			(
			'{F3B79F92-3917-4a42-90EB-0F854EB683E7}' --alamo guid
			,1 --version number
			,'172.18.18.255'-- ca.VarValue
			,'255.255.255.0'--ma.VarValue
		  ,CAST(cp.VarValue as int)
		  , '<ALAMO version=''1''><MESS type=''ChangeOfGamingDate'' StockTypeID=''' + 
		  cast (st.[StockTypeID] AS VARCHAR(16)) + ''' GamingDate=''' +
		  [GeneralPurpose].[fn_CastDateForAdoRead] ( 
				GeneralPurpose.fn_GetGamingLocalDate2(
						GetUTCDate(),
						--pass current hour difference between local and utc 
						DATEDIFF (hh , GetUTCDate(),GetDate()),
						st.[StockTypeID]
						)
						)+ ''' EuroRate=''' + cast (ISNULL(IntRate,0) AS VARCHAR(32) ) + ''' /></ALAMO>'
						)	
	FROM [CasinoLayout].[StockTypes] st ,
	[GeneralPurpose].[ConfigParams] cp,
--	[GeneralPurpose].[ConfigParams] ca,
--	[GeneralPurpose].[ConfigParams] ma,
	[Accounting].vw_LastEuroRate r
	WHERE CAST(REPLACE([ChangeOfGamingDate],':00','') AS INT) =	DATEPART(HOUR,GETDATE())
		and cp.VarName = 'AlamoMessagesPort'
--		and ca.VarName = 'AlamoMessagesNetwork'
--		and ma.VarName = 'AlamoMessagesMask'
	SET @c = @@ROWCOUNT
/*lm rimossa la funzionalita 1.5.2018
	--re-enable bus cinese message in case it has been disbled during the day
	--when date changes for cassa centrale
	IF EXISTS (
		SELECT st.StockTypeID
		FROM [CasinoLayout].[StockTypes] st 
		WHERE st.StockTypeID = 7 --main trolleys
		AND CAST(REPLACE([ChangeOfGamingDate],':00','') AS INT) = DATEPART(HOUR,GETDATE()) 
	)
	and  EXISTS -- and bus cinesi is disabled
	(
		SElect VarValue
		FROM [GeneralPurpose].[ConfigParams]
		where [VarName] = 'BusCinesiEnabled' and VarType = 3 AND VarValue = '0'
	)
	BEGIN
		--than reset enabling of bus cinesi
		update [GeneralPurpose].[ConfigParams]
		SET VarValue = '1'
		where [VarName] = 'BusCinesiEnabled' and VarType = 3

		PRINT 'Bus cinesi re-enabled'
	end
	*/
RETURN 0
GO
