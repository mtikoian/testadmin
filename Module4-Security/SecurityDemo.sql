--Sam Nasr MCSA, MVP
--SQL Server 2016 Security Features Demo
--Requires SQL Server 2016 (any edition)

IF DB_ID(N'SecurityDemoDB') IS NOT NULL 
  DROP DATABASE SecurityDemoDB;
GO

CREATE DATABASE SecurityDemoDB;
Go

USE SecurityDemoDB;
GO

/**************************************/
/* Demo #1: Dynamic Data Masking (DDM)*/
/**************************************/

-- Populating tables with sample data 
CREATE TABLE Customers   
(    
     [Id] int identity(1,1) NOT NULL PRIMARY KEY CLUSTERED  
   , [FirstName] varchar(50) NOT NULL
   , [LastName] varchar(50) NOT NULL
   , [Address] varchar(100) NOT NULL
   , [Email] varchar(50) MASKED WITH (FUNCTION = 'partial(3, "xyz", 1)')  NULL
   , [SSN] varchar(11) MASKED WITH (FUNCTION = 'default()') NOT NULL
)    
GO

INSERT INTO [dbo].[Customers] ([FirstName], [LastName], [Address], [Email], [SSN])
                       VALUES ('Lisa', 'Shepherd', '1212 Middle Street, Cleveland, OH  44118', 'lisa@gmail.com', '111-22-3333')
					         ,('Tina', 'Wilson', '5582 South Street, Naples, FL  34101', 'tinaw@outlook.com', '222-33-4444')
							 ,('Sam', 'Johnson', '2418 North Woods Ave, Seattle, WA  98116', 'SamuelJohnson@yahoo.com', '333-44-5555')
GO

select * from [dbo].[Customers]


--Adding DDM to an existing table
ALTER TABLE [dbo].[Customers] ALTER COLUMN [LastName] ADD MASKED WITH (FUNCTION = 'default()');
select * from [dbo].[Customers]

--Removing DDM
ALTER TABLE [dbo].[Customers] ALTER COLUMN [LastName] DROP MASKED
select * from [dbo].[Customers]


select * from sys.database_principals
select * from sys.database_role_members

-- Syntax for SQL Server (starting with 2012) and Azure SQL Database  
--ALTER ROLE  role_name  
--{  
--       ADD MEMBER database_principal  
--    |  DROP MEMBER database_principal  
--    |  WITH NAME = new_name  
--}  

CREATE USER SamR WITHOUT LOGIN;
GRANT SELECT ON dbo.customers TO SamR  --GRANT CONNECT TO SamR;  
EXECUTE AS USER='SamR'
SELECT USER_NAME(); 
SELECT * FROM [dbo].[Customers]


----GRANT UNMASK rights
REVERT; 
SELECT USER_NAME();  
SELECT * FROM [dbo].[Customers]    
GRANT UNMASK TO SamR
EXECUTE AS USER='SamR'
SELECT USER_NAME(); 
SELECT * FROM [dbo].[Customers]


--Revoke UNMASK rights
REVERT; 
REVOKE UNMASK TO SamR
SELECT USER_NAME();  
SELECT * FROM [dbo].[Customers]



/***************************************************************/
/* Demo #2: Always Encrypted                                   */
/* Before executing this step, the following must be created   */
/*   A. Column Master Key                                      */
/*   B. Column Encryption Key                                  */
/***************************************************************/
CREATE TABLE Employees   
(    
     [Id] int identity(1,1) NOT NULL PRIMARY KEY CLUSTERED  
   , [FirstName] varchar(50) NOT NULL
   , [LastName] varchar(50) NOT NULL
   , [SSN] varchar(11) COLLATE Latin1_General_BIN2   
           ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC,   
		                   ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',    
						   COLUMN_ENCRYPTION_KEY = SSNKey) 
	NOT NULL
)    
GO

USE SecurityDemoDB;
GO

DECLARE @SSN varCHAR(11) = '795-73-9838'
INSERT INTO [dbo].[Employees] ([FirstName], [LastName], [SSN])
                       VALUES ('Lisa', 'Shepherd', @SSN)
					   --      ,('Tina', 'Wilson', '222-33-4444')
							 --,('Sam', 'Johnson', '333-455')
GO


select * from dbo.Employees

-- Can use "Column Encryption Setting = Enabled" when connecting SSMS to see data

/**************************************/
/* Demo #3: Row Level Security        */
/**************************************/
CREATE TABLE Orders ( OrderId int, SalesRep sysname );
Go

CREATE FUNCTION dbo.fn_Orders(@SalesRep AS sysname) 
RETURNS TABLE WITH SCHEMABINDING AS RETURN SELECT 1 AS fn_Orders_result 
WHERE @SalesRep = USER_NAME(); 
GO

INSERT INTO [dbo].[Orders] ([OrderId], [SalesRep])
                    VALUES ('102', 'dbo')

select * from dbo.orders 

CREATE SECURITY POLICY dbo.OrderPolicy 
ADD FILTER PREDICATE dbo.fn_Orders(SalesRep) ON dbo.Orders WITH (STATE=ON);

SELECT USER_NAME();
GRANT SELECT ON dbo.orders TO SamR 
EXECUTE AS USER='SamR'
SELECT * FROM [dbo].[Orders]
REVERT;
SELECT USER_NAME();