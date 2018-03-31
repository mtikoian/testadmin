
USE AdventureWorks2012
GO

SET STATISTICS TIME,IO ON
SELECT e.businessentityid, 
       p.title, 
       p.firstname, 
       p.middlename, 
       p.lastname, 
       p.suffix, 
       e.jobtitle, 
       d.NAME AS Department, 
       d.groupname, 
       edh.startdate 
FROM   humanresources.employee AS e 
       INNER JOIN person.person AS p 
               ON p.businessentityid = e.businessentityid 
       INNER JOIN humanresources.employeedepartmenthistory AS edh 
               ON e.businessentityid = edh.businessentityid 
       INNER JOIN humanresources.department AS d 
               ON edh.departmentid = d.departmentid 
WHERE  ( edh.enddate IS NULL ) 

GO

SELECT e.businessentityid, 
       p.title, 
       p.firstname, 
       p.middlename, 
       p.lastname, 
       p.suffix, 
       e.jobtitle, 
       d.NAME AS Department, 
       d.groupname, 
       edh.startdate 
FROM   humanresources.employee AS e 
       INNER JOIN person.person AS p 
               ON p.businessentityid = e.businessentityid 
       INNER JOIN humanresources.employeedepartmenthistory AS edh 
               ON e.businessentityid = edh.businessentityid 
       INNER JOIN humanresources.department AS d 
               ON edh.departmentid = d.departmentid 
WHERE  ( edh.enddate IS NULL ) 
OPTION (QUERYTRACEON 2312)
GO

SET STATISTICS TIME,IO ON