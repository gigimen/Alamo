SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Techs].[vw_AllProblemaSlotSubTypes]
WITH SCHEMABINDING
AS
SELECT    
	s.ProblemaSlotSubTypeID,
	s.ProblemaSlotSubTypeDescription,
	s.ProblemaSlotTypeID,
	p.ProblemaSlotTypeDescription
FROM Techs.ProblemaSlotSubTypes s
inner join Techs.ProblemaSlotTypes p on p.ProblemaSlotTypeID = s.ProblemaSlotTypeID






GO
