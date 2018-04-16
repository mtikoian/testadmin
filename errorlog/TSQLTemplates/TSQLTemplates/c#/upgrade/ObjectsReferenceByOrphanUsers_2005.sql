/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2005 & UP

	NAME:           OBJECTSREFERENCEBYORPHANUSERS_2005.SQL

    DESCRIPTION:    THIS SCRIPT REPORTS HELPS YOU IDENTIFY WHAT OBJECTS THE ORPHAN
                    USER OWNS OR BEING REFERENCE
                    
    INPUT:          NONE
    
    OUTPUT:         RETURNS A RESULTSET OF OBJECTS ORPHAN USERS OWNS 
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        01/17/2012 1.00     INITIAL CREATION
   *******************************************************************************
*/
SELECT      A.name              AS SQLUser
            ,B.name             AS SchemaName
            ,C.name             AS ObjectName
            ,C.type_desc        AS ObjectType
            ,'Owns Schema'      AS OwnershipType
FROM        sys.database_principals A            
                JOIN sys.schemas B ON A.principal_id = B.principal_id
                JOIN sys.all_objects C ON B.schema_id = C.schema_id -- OBJECTS OWNED BY SCHEMA OWNER
                LEFT JOIN master.sys.server_principals D ON A.sid = D.sid
WHERE       A.type IN ('S')            
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       D.sid IS NULL
UNION ALL               
SELECT      A.name              AS SQLUser
            ,C.name             AS SchemaName
            ,B.name             AS ObjectName
            ,B.type_desc        AS ObjectType
            ,'Owns Object'      AS OwnershipType
FROM        sys.database_principals A            
                JOIN sys.all_objects B ON A.principal_id = B.principal_id -- OBJECTS OWNED BY PRINCIPAL VIA ALTER AUTHORIZATION
                JOIN sys.schemas C ON B.schema_id = C.schema_id   
                LEFT JOIN master.sys.server_principals D ON A.sid = D.sid
WHERE       A.type IN ('S')            
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       D.sid IS NULL
  AND       B.principal_id IS NOT NULL
  AND       B.principal_id <> C.principal_id -- OWNER OF OBJECT DIFFERENT FROM OWNER OF SCHEMA
UNION ALL
SELECT      A.name              AS SQLUser
            ,D.name             AS SchemaName
            ,C.name             AS ObjectName
            ,C.type_desc        AS ObjectType
            ,'Uses EXECUTE AS'  AS OwnershipType
FROM        sys.database_principals A            
                JOIN sys.sql_modules B ON A.principal_id = B.execute_as_principal_id
                JOIN sys.all_objects C ON B.object_id = C.object_id
                JOIN sys.schemas D ON C.schema_id = D.schema_id
                LEFT JOIN master.sys.server_principals E ON A.sid = E.sid
WHERE       A.type IN ('S')            
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       E.sid IS NULL
UNION ALL
SELECT      A.name                          AS SQLUser
            ,F.name                         AS SchemaName
            ,E.name                         AS ObjectName
            ,E.type_desc                    AS ObjectType
            ,'Object Depends On ' + 
                QUOTENAME(B.name) + '.' + 
                QUOTENAME(C.name)           AS OwnershipType
FROM        sys.database_principals A            
                JOIN sys.schemas B ON A.principal_id = B.principal_id
                JOIN sys.all_objects C ON B.schema_id = C.schema_id -- OBJECTS OWNED BY SCHEMA OWNER
                JOIN sys.sql_expression_dependencies D ON C.object_id = D.referenced_id
                JOIN sys.all_objects E ON D.referencing_id = E.object_id
                JOIN sys.schemas F ON E.schema_id = F.schema_id
                LEFT JOIN master.sys.server_principals G ON A.sid = G.sid
WHERE       A.type IN ('S')            
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       G.sid IS NULL
UNION ALL
SELECT      A.name                          AS SQLUser
            ,F.name                         AS SchemaName
            ,E.name                         AS ObjectName
            ,E.type_desc                    AS ObjectType
            ,'Object Depends On ' + 
                QUOTENAME(C.name) + '.' + 
                QUOTENAME(B.name)           AS OwnershipType
FROM        sys.database_principals A            
                JOIN sys.all_objects B ON A.principal_id = B.principal_id -- OBJECTS OWNED BY PRINCIPAL VIA ALTER AUTHORIZATION
                JOIN sys.schemas C ON B.schema_id = C.schema_id   
                JOIN sys.sql_expression_dependencies D ON B.object_id = D.referenced_id
                JOIN sys.all_objects E ON D.referencing_id = E.object_id
                JOIN sys.schemas F ON E.schema_id = F.schema_id
                LEFT JOIN master.sys.server_principals G ON A.sid = G.sid
WHERE       A.type IN ('S')            
  AND       A.sid NOT IN (0x00, 0x01) -- ignore guest & dbo
  AND       A.sid IS NOT NULL
  AND       G.sid IS NULL
  