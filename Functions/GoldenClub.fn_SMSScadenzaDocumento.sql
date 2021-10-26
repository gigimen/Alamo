SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO




CREATE   FUNCTION [GoldenClub].[fn_SMSScadenzaDocumento] (
@sesso 	bit,
@LastName varchar(256),
@expdate datetime,
@MemberTypeID int
)
RETURNS varchar(512) 
AS  
BEGIN 
	declare @messaggio varchar(512)
	if @sesso = 1
		set @messaggio = 'Gent. Sig.ra ' + @Lastname + ' 
'
	else
		set @messaggio = 'Egr. Sig. ' + @Lastname + ' 
'

	set @messaggio = @messaggio + 'CAM Le ricorda che il suo documento di identità scade il ' +  
convert(varchar(32),@expdate,106) +'.
Per il rinnovo della tessera ' 
	/*if @MemberTypeID = 1
		set @messaggio = @messaggio + 'GoldenClub' 
	else	if @MemberTypeID = 2
		set @messaggio = @messaggio + 'DragonClub' 
	else	if @MemberTypeID = 3
		*/set @messaggio = @messaggio + 'AdmiralClub' 
	
	set @messaggio = @messaggio + ', alla prossima visita voglia cortesemente presentare un documento in corso di validità.'
	return @messaggio
END














GO
