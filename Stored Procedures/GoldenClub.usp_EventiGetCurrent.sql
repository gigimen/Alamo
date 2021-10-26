SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [GoldenClub].[usp_EventiGetCurrent] 
@tot int output,
@memb int OUTPUT,
@EstrazioneDone int output
AS

declare @g datetime

set @g = GeneralPurpose.fn_GetGamingLocalDate2(getUTCDate(),1,4)


select 
	@tot = count(*) + ISNULL(SUM(Accompagnatori),0),
	@memb = count(*),
	@EstrazioneDone = COUNT(CASE WHEN Winner=1 THEN 1 ELSE NULL END)
from GoldenClub.tbl_PartecipazioneEventi p
INNER JOIN Marketing.tbl_Eventi e ON e.EventoID = p.EventoID
where e.gamingdate = @g


select EventoID,Nome,DragonAndGolden,[ProjectorComputer],[Auguri]
from Marketing.tbl_Eventi
where gamingdate = @g

GO
