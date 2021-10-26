SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Marketing].[vw_Natale2017_Consegna]
AS
select 'Consegna: Vignette (' + cast(v.Vignette as varchar(16)) + '/' + cast(v2.Vignette as varchar(16)) + ') Stazioni Bluetooth (' + cast(s.Stazioni as varchar(16)) + '/' + cast(s2.Stazioni as varchar(16)) + ')' as Consegna
from
(
	SELECT counT(distinct v.AssegnazionePremioID) as Vignette
	from [Marketing].[tbl_AssegnazionePremi] v
	where (v.OffertaPremioID = 98 and v.RitiratoTimeStampUTC is not null) 
)v
cross join
(
	SELECT counT(distinct v.AssegnazionePremioID) as Vignette
	from [Marketing].[tbl_AssegnazionePremi] v
	where (v.OffertaPremioID = 98 and v.CancelTimeUTC is null) 
)v2
cross join
(
	SELECT counT(distinct s.AssegnazionePremioID) as Stazioni
	from [Marketing].[tbl_AssegnazionePremi] s 
	where (s.OffertaPremioID = 99 and s.RitiratoTimeStampUTC is not null)
) s
cross join
(
	SELECT counT(distinct s.AssegnazionePremioID) as Stazioni
	from [Marketing].[tbl_AssegnazionePremi] s 
	where s.OffertaPremioID = 99 and s.CancelTimeUTC is null
) s2
GO
