SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Techs].[vw_AllProblemaLiveGameSubTypes]
WITH SCHEMABINDING
AS
SELECT    
	s.ProblemaLiveGameSubTypeID,
	s.ProblemaLiveGameSubTypeDescription,
	s.ProblemaLiveGameTypeID,
	p.ProblemaLiveGameTypeDescription
FROM Techs.ProblemaLiveGameSubTypes s
inner join Techs.ProblemaLiveGameTypes p on p.ProblemaLiveGameTypeID = s.ProblemaLiveGameTypeID










GO
