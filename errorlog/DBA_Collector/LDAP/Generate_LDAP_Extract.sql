 SET NOCOUNT ON;      
      
 WITH      
 UserBlackJackRolesToLDAPRoles (UserID, LDAPRoles)      
 AS(      
  Select U.UserID,BR.RoleName from BlackjackRole BR join UsersRoles UR on BR.Roleid = UR.Roleid 
		right join Users U on U.Id = UR.UserId Join Users_helper UH ON U.UserID = UH.UserId_Login       
 ),      
           
 UserBlackJackRolesToAllLDAPRoles (UserID, LDAPRoles)      
 AS (      
 SELECT   UserID      
   ,STUFF((SELECT ', ' + CAST(LDAPRoles AS VARCHAR(1000)) [text()]       
 FROM UserBlackJackRolesToLDAPRoles      
 WHERE UserID = t.UserID      
    FOR XML PATH(''), TYPE)      
   .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output      
 FROM UserBlackJackRolesToLDAPRoles t      
 GROUP BY UserID      
 ),
 
 UserLDAPAttributes(UserID,LDAPValue)
As
(
Select U.UserID,BFl.LdapValue from UsersFeatures UF Join BlackjackFeatureLdapAttribute BFL 
on UF.FeatureId = BFL.FeatureId 
join Users U on U.Id = UF.UserId
join Users_helper UH on UH.UserId_Login = U.UserID
Where BFL.FeatureId in (14,141,142,143)
),

UserCommaLDAPAtt (UserID, LDAPRoles)      
 AS (      
 SELECT   UserID      
   ,STUFF((SELECT ', ' + CAST(LDAPValue AS VARCHAR(1000)) [text()]       
 FROM UserLDAPAttributes      
 WHERE UserID = t.UserID      
    FOR XML PATH(''), TYPE)      
   .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output      
 FROM UserLDAPAttributes t      
 GROUP BY UserID      
 )
 ,
 UserALLLDAPAttri(UserID,LDAPvalue)
 As(
 Select UserId_Login,UH.LdapCompanyTypeAttribute + ',' +UC.LDAPRoles from UserCommaLDAPAtt UC  
  Join Users_helper UH on UC.Userid = UH.UserId_Login),
  
  AllUserswithLDAPValues(UserID,LDAPVALUE)
  AS(  
  Select UH.UserId_Login,
  CASE WHEN ULA.LDAPvalue IS NULL 
  THEN
  UH.LdapCompanyTypeAttribute
  ELSE
  ULA.LDAPvalue 
  END
  from Users_helper UH left join UserALLLDAPAttri ULA on
  UH.UserId_Login = ULA.UserID
  JOIN Users U on U.UserID = UH.UserId_Login
 )
    
SELECT   a.companyid,    
  'Null' AS [ClickDB / Powerlink ref ID]     
    ,'Null' AS [Hvac Brands]  
    ,'Null' AS   [E-mail address]  
    ,'Null'    AS [User First Name]  
    ,'Null'   AS [User Last Name]  
    ,A.UserId_Login AS [User Id/Login Id] 
    ,'Null' As [Password] -- Change it for each load 
    ,'Null' AS [Blackjack Role Claims (for LDAP)]   
    ,'Null'  AS [BlackJack Additional Features]  
    ,'Null' AS [CRM Company Type]  
    ,ULA.LDAPvalue AS [Company Services]   
    ,'Null' AS [SiteAccess]  
FROM Users_helper A  
JOIN Users U on A.UserId_Login = U.UserID     
JOIN UserBlackJackRolesToAllLDAPRoles B ON A.UserId_Login = B.UserID  
 JOIN AllUserswithLDAPValues ULA ON ULA.UserID = A.UserId_Login
ORDER BY  A.UserId_Login ;   