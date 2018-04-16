--===== Do this in a nice, safe place that everyone has
    USE tempdb;
GO
 CREATE PROCEDURE dbo.BuildSmallEmployeeTable AS
/****************************************************************************
 Purpose:
 Create a standard "well formed" Adjacency List hierarchy with indexes.

 This procedure takes no parameters.

 Usage: 
   EXEC dbo.BuildSmallEmployeeTable;

 Revision History:
 Initial creation - Circa 2009 - Jeff Moden
 Rev 01 - 15 May 2010 - Jeff Moden 
        - Abort if current DB isn't "tempdb" to protect users.
****************************************************************************/
--===========================================================================
--      Presets
--===========================================================================
--===== Supresss the autodisplay of rowcounts to cleanup the display and to
     -- prevent false error returns if called from a GUI.
    SET NOCOUNT ON;

--===== Make sure that we're in a safe place to run this...
     IF DB_NAME() <> N'tempdb'
  BEGIN
        RAISERROR('Current DB is NOT tempdb. Run aborted.',11,1);
        RETURN;
    END;

--===== Conditionaly drop the test table so we can do reruns more easily
     IF OBJECT_ID('tempdb.dbo.Employee','U') IS NOT NULL
        DROP TABLE tempdb.dbo.Employee;

--===========================================================================
        RAISERROR('Building the hierarchy table...',0,1) WITH NOWAIT;
--===========================================================================
--===== Create the test table with a clustered PK and an FK to itself to make
     -- sure that a ManagerID is also an EmployeeID.
 CREATE TABLE dbo.Employee
        (
        EmployeeID      INT             NOT NULL,
        ManagerID       INT             NULL,
        EmployeeName    VARCHAR(10)     NOT NULL,
        CONSTRAINT  PK_Employee          
                    PRIMARY KEY CLUSTERED (EmployeeID),
        CONSTRAINT  FK_Employee_Employee 
                    FOREIGN KEY (ManagerID)
                    REFERENCES dbo.Employee (EmployeeID)
                    ON UPDATE NO ACTION 
                    ON DELETE NO ACTION
        )
;
--===========================================================================
        RAISERROR('Populate the hierarchy table...',0,1) WITH NOWAIT;
--===========================================================================
--===== Populate the test table with test data. Each child ID has a parent ID
     -- adjacent to it on the same row which is why it's called an "Adjacency
     -- List".
 INSERT INTO dbo.Employee
        (EmployeeID, ManagerID, EmployeeName)
 SELECT 26,NULL,'Jim'     UNION ALL
 SELECT  2,  26,'Lynne'   UNION ALL
 SELECT  3,  26,'Bob'     UNION ALL
 SELECT  6,  17,'Eric'    UNION ALL
 SELECT  8,   3,'Bill'    UNION ALL
 SELECT  7,   3,'Vivian'  UNION ALL
 SELECT 12,   8,'Megan'   UNION ALL
 SELECT 14,   8,'Kim'     UNION ALL
 SELECT 17,   2,'Butch'   UNION ALL
 SELECT 18,  39,'Lisa'    UNION ALL
 SELECT 20,   3,'Natalie' UNION ALL
 SELECT 21,  39,'Homer'   UNION ALL
 SELECT 39,  26,'Ken'     UNION ALL
 SELECT 40,  26,'Marge'  
;
RAISERROR('There are %u rows in the hierarchy.',0,1,@@ROWCOUNT) WITH NOWAIT;
--===========================================================================
        RAISERROR('Adding an additional index ...',0,1) WITH NOWAIT;
--===========================================================================
--===== Create an additional index to speed things up
 CREATE UNIQUE INDEX By_ManagerID_EmployeeID 
     ON TempDB.dbo.Employee (ManagerID,EmployeeID)
;       
--===========================================================================
--      Exit
--===========================================================================
RAISERROR('===============================================',0,1) WITH NOWAIT;
RAISERROR('RUN COMPLETE',0,1) WITH NOWAIT;
RAISERROR('===============================================',0,1) WITH NOWAIT;
GO