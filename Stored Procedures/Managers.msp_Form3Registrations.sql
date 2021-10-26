SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE   PROCEDURE [Managers].[msp_Form3Registrations]
@CustID int,
@GamingDate datetime, 
@Direction varchar(16)  ,
@tot int output
AS  
BEGIN 
	declare @ret int 

	set @ret = CURSOR_STATUS ('global','reg_cursor')
	print 'CURSOR_STATUS returned ' + cast(@ret as varchar) 
	if @ret > -3
	begin
		print 'deallocting reg_cursor'
		DEALLOCATE reg_cursor
	end
	
	set @tot = 0
	
	DECLARE reg_cursor CURSOR
	   FOR
	select r.RegID,AmountSFr,TimeStampUTC
	from Snoopy.tbl_Registrations r
	inner join Snoopy.tbl_IDCauses i on i.IDCauseID = r.CauseID
	where r.GamingDate = @GamingDate 
	and r.CancelID is null
	and r.CustomerID = @CustID
	and i.Direction = @Direction
	order by TimeStampUTC

	OPEN reg_cursor
	DECLARE @am int
	declare @sum int
	declare @RegID int
	declare @ts datetime
	set @sum = 0
	FETCH NEXT FROM reg_cursor INTO @RegID,@am,@ts
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
	   --print @RegID
	   --print @am
	   --print '---------------'
		set @sum = @sum + @am
		if @sum >= 15000
		begin
			--print 'REGISTRAZIONE DI ' + cast (@sum as varchar (16)) 

			insert into Snoopy.tbl_Registrations
			(
				[RegID]
				  ,[CustomerID]
				  ,[StockID]
				  ,[TimeStampUTC]
				  ,[GamingDate]
				  ,[CauseID]
				  ,[AmountSFr]
				  ,[UserAccessID]
				  ,[CancelID]
				  ,[TimeStampLoc]
			)
			select 
				RegID,
				r.CustomerID,
				r.StockID,	
				r.TimeStampUTC,
				r.GamingDate,
				r.CauseID,
				@sum,
				r.UserAccessID,
				NULL,
				r.TimeStampLoc
			from Snoopy.tbl_Registrations r
				where RegID = @RegID
			set @tot = @tot + @@rowcount		
			set @sum = 0
		end
	   FETCH NEXT FROM reg_cursor INTO @RegID,@am,@ts
	END
	if CURSOR_STATUS ('global','reg_cursor') > -3
		DEALLOCATE reg_cursor	
		
		
		--finally insert also registrations that did not sum up to 15000
	insert into Snoopy.tbl_Registrations
	(
		[RegID]
		  ,[CustomerID]
		  ,[StockID]
		  ,[TimeStampUTC]
		  ,[GamingDate]
		  ,[CauseID]
		  ,[AmountSFr]
		  ,[UserAccessID]
		  ,[CancelID]
		  ,[TimeStampLoc]
	)
	select m.[RegID]
		  ,m.[CustomerID]
		  ,m.[StockID]
		  ,m.[TimeStampUTC]
		  ,m.[GamingDate]
		  ,m.[CauseID]
		  ,m.[AmountSFr]
		  ,m.[UserAccessID]
		  ,m.[CancelID]
		  ,m.[TimeStampLoc]
	from 
	(
		select		
			r.[RegID]
		  ,r.[CustomerID]
		  ,r.[StockID]
		  ,r.[TimeStampUTC]
		  ,r.[GamingDate]
		  ,r.[CauseID]
		  ,r.[AmountSFr]
		  ,r.[UserAccessID]
		  ,r.[CancelID]
		  ,r.[TimeStampLoc]
		  ,i2.Direction 
		from Snoopy.tbl_Registrations r
		inner join Snoopy.tbl_IDCauses i2 on i2.IDCauseID = r.CauseID
		left outer join Snoopy.tbl_Registrations r2 on r2.RegID = r.RegID
		where r2.RegID is null and r.CancelID is null
	) m
	inner join 
	(
	select 
		max(RegID) as ultregid,
		r.CustomerID,
		r.GamingDate,
		max([TimeStampUTC]) as maxtime,
		i.Direction
		from Snoopy.tbl_Registrations r
		inner join Snoopy.tbl_IDCauses i on i.IDCauseID = r.CauseID
		where r.GamingDate < '1.1.2008' 
		and r.CancelID is null
		group by r.CustomerID,
		r.GamingDate,
		i.Direction
	) ult on ult.CustomerID = m.CustomerID and ult.GamingDate = m.GamingDate and ult.Direction = m.Direction
	where m.CustomerID = @CustID
	and m.CancelID is null
	and m.GamingDate = @GamingDate
	and m.TimestampUTC > ult.maxtime
	and m.RegID <> ult.ultregid


	set @tot = @tot + @@rowcount		

return @ret
		
END
GO
