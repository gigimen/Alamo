SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [Managers].[msp_ClearCassierePasswords]
AS
 
 
 update CasinoLayout.Users
 set Password = null
 where userid in (select userid from CasinoLayout.UserGroup_User where usergroupid in(9,10))

 select UserID,LastName,Password from CasinoLayout.Users
 where userid in (select userid from CasinoLayout.UserGroup_User where usergroupid in(9,10))
GO
