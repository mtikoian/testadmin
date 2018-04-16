/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2000

	NAME:           OBJECTSREFERENCEBYORPHANUSERS_2000.SQL

    DESCRIPTION:    THIS SCRIPT REPORTS HELPS YOU IDENTIFY WHAT OBJECTS THE ORPHAN
                    USER OWNS 
                    
    INPUT:          NONE
    
    OUTPUT:         RETURNS A RESULTSET OF OBJECTS ORPHAN USERS OWNS 
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        01/17/2012 1.00     INITIAL CREATION
   *******************************************************************************
*/
SET NOCOUNT ON

SELECT      A.name              AS SQLUser
            ,A.name             AS SchemaName
            ,B.name             AS ObjectName
            ,CASE xtype 
                WHEN  'C' THEN 'CHECK constraint'
                WHEN  'D' THEN 'Default or DEFALT constraint'
                WHEN  'F' THEN 'FOREIGN KEY constraint'
                WHEN  'L' THEN 'Log' 
                WHEN 'FN' THEN 'Scalar function'
                WHEN 'IF' THEN 'Inlined table-function'        
                WHEN  'P' THEN 'Stored procedure'
                WHEN 'PK' THEN 'PRIMARY KEY constraint'
                WHEN 'RF' THEN 'Replicaiton filter stored procedure'
                WHEN  'S' THEN 'System table'
                WHEN 'TF' THEN 'Table function'
                WHEN 'TR' THEN 'Trigger'
                WHEN  'U' THEN 'User table'
                WHEN 'UQ' THEN 'UNIQUE constraint'
                WHEN  'V' THEN 'View'
                WHEN  'X' THEN 'Extended stored procedure'
                ELSE xtype
            END                 AS ObjectType
            ,'Owns Object'      AS OwnershipType
FROM        sysusers A            
                JOIN sysobjects B ON A.uid = B.uid -- OBJECTS OWNED BY USER
                LEFT JOIN master.dbo.syslogins C ON A.sid = C.sid
WHERE       A.issqluser = 1
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       C.sid IS NULL
UNION ALL
SELECT      DISTINCT
            A.name              AS SQLUser
            ,E.name             AS SchemaName
            ,D.name             AS ObjectName
            ,CASE D.xtype 
                WHEN  'C' THEN 'CHECK constraint'
                WHEN  'D' THEN 'Default or DEFALT constraint'
                WHEN  'F' THEN 'FOREIGN KEY constraint'
                WHEN  'L' THEN 'Log' 
                WHEN 'FN' THEN 'Scalar function'
                WHEN 'IF' THEN 'Inlined table-function'        
                WHEN  'P' THEN 'Stored procedure'
                WHEN 'PK' THEN 'PRIMARY KEY constraint'
                WHEN 'RF' THEN 'Replicaiton filter stored procedure'
                WHEN  'S' THEN 'System table'
                WHEN 'TF' THEN 'Table function'
                WHEN 'TR' THEN 'Trigger'
                WHEN  'U' THEN 'User table'
                WHEN 'UQ' THEN 'UNIQUE constraint'
                WHEN  'V' THEN 'View'
                WHEN  'X' THEN 'Extended stored procedure'
                ELSE D.xtype
            END                         AS ObjectType
            ,'Object Depends On ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name)     AS OwnershipType
FROM        sysusers A            
                JOIN sysobjects B ON A.uid = B.uid -- OBJECTS OWNED BY USER
                JOIN sysdepends C ON B.id = C.depid
                JOIN sysobjects D ON C.id = D.id
                JOIN sysusers E ON D.uid = E.uid
                LEFT JOIN master.dbo.syslogins F ON A.sid = F.sid
WHERE       A.issqluser = 1
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       F.sid IS NULL



