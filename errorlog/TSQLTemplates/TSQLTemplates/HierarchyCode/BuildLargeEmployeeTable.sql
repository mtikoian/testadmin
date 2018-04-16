--===== Do this in a nice, safe place that everyone has
    USE tempdb;
GO
 CREATE PROCEDURE dbo.BuildLargeEmployeeTable
/****************************************************************************
 Purpose:
 Create a randomized "well formed" Adjacency List hierarchy with indexes.

 Progammer's Notes:

 1. Each EmployeeID (except for the Root Node, of course) is assigned a
    random ManagerID number which is initially always less than the current
    EmployeeID to ensure that no cycles occur in the hierarcy.

 2. The second parameter used to call this stored procedure will optionally
    randomize the EmployeeIDss to make the hierarchy truly random as it would
    likely be in real life.  This, of course, takes a small amounnt of extra
    time.

 3. This code runs nasty fast and is great for testing hierarchical
    processing code. Including the index builds, this code will build a
    million node Adjacency List on a 4 processor (i5) laptop with 6GB of RAM
    in just several seconds.  The optional randomization adds just several 
    more seconds.

 Usage: 
--===== Create the hierarchy where all the ManagerIDs are less than the
     -- EmployeeIDs. This is the fastest option and will build a million node
     -- hierarchy in just about 7 seconds on a modern machine.
   EXEC dbo.BuildLargeEmployeeTable 1000000;

--===== Making the second parameter a non-zero value will further randomize
     -- the IDs in the hierarchy. This, of course, takes extra time and will
     -- build a million row hierarchy in about 17 seconds on a modern 
     -- machine.
   EXEC dbo.BuildLargeEmployeeTable 1000000,1;

 Revision History:
 Initial concept and creation - Circa 2009 - Jeff Moden
 Rev 01 - 15 May 2010 - Jeff Moden 
        - Abort if current DB isn't "tempdb" to protect users.
 Rev 02 - 13 Oct 2012 - Jeff Moden
        - Add a randomization stop to make the hierarchy more like real life.
****************************************************************************/
--===== Declare the I/O parameters
        @pRowsToBuild INT,
        @pRandomize  TINYINT = 0
     AS

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
        RAISERROR('Building the hierarchy...',0,1) WITH NOWAIT;
--===========================================================================
--===== Build the test table and populate it on the fly.
     -- Everything except ManagerID is populated here. The code uses a 
     -- technique called a "Psuedo-Cursor" (kudos to R. Barry Young for the
     -- term) to very quickly and easily build large numbers of rows.
 SELECT TOP (@pRowsToBuild)
        EmployeeID   = ISNULL(CAST(
                          ROW_NUMBER() OVER (ORDER BY (SELECT 1))
                       AS INT),0),
        ManagerID    = CAST(NULL AS INT),
        EmployeeName = CAST(NEWID() AS VARCHAR(36))
   INTO TempDB.dbo.Employee
   FROM master.sys.all_columns ac1
  CROSS JOIN master.sys.all_columns ac2
  CROSS JOIN master.sys.all_columns ac3
;
RAISERROR('There are %u rows in the hierarchy.',0,1,@@ROWCOUNT) WITH NOWAIT;

--===== Update the test table with ManagerID's.  The ManagerID is some random
     -- value which is always less than the current EmployeeID to keep the 
     -- hierarchy "clean" and free from "loop backs".
 UPDATE TempDB.dbo.Employee
    SET ManagerID = CASE 
                       WHEN EmployeeID > 1 
                       THEN ABS(CHECKSUM(NEWID())) % (EmployeeID-1) +1 
                       ELSE NULL 
                   END
;
--===========================================================================
--      Conditionally randomize the hierarchy to be more like real life
--===========================================================================
     IF @pRandomize <> 0
  BEGIN
        --===== Alert the operator
                RAISERROR('Randomizing the hierarchy...',0,1) WITH NOWAIT;

        --===== Create a randomized cross reference list to randomize the
             -- EmployeeIDs with.
         SELECT RandomEmployeeID = IDENTITY(INT,1,1),
                EmployeeID
           INTO #RandomXRef
           FROM dbo.Employee
          ORDER BY NEWID()
        ;
        --===== Update the ManagerIDs in the Employee table with the new 
             -- randomized IDs
         UPDATE emp
            SET emp.ManagerID = RandomEmployeeID
           FROM dbo.Employee emp
           JOIN #RandomXRef xref ON emp.ManagerID = xref.EmployeeID
        ;
        --===== Update the EmployeeIDs in the Employee table with the new 
             --randomized IDs
         UPDATE emp
            SET emp.EmployeeID = RandomEmployeeID
           FROM dbo.Employee emp
           JOIN #RandomXRef xref ON emp.EmployeeID = xref.EmployeeID
        ;
    END
   ELSE
  BEGIN
        --===== Alert the operator
                RAISERROR('The hierarchy is not randomized',0,1) WITH NOWAIT;
    END
;
--===========================================================================
--      Build the indexes necessary for performance.
--===========================================================================
--===== Alert the operator
        RAISERROR('Building the keys and indexes...',0,1) WITH NOWAIT;

--===== Add some indexes that most folks would likely have on such a table
  ALTER TABLE TempDB.dbo.Employee 
    ADD CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (EmployeeID)
;
 CREATE UNIQUE INDEX By_ManagerID_EmployeeID 
     ON TempDB.dbo.Employee (ManagerID,EmployeeID)
;
  ALTER TABLE dbo.Employee 
    ADD CONSTRAINT FK_Employee_Employee FOREIGN KEY
        (ManagerID) REFERENCES dbo.Employee (EmployeeID) 
     ON UPDATE NO ACTION 
     ON DELETE NO ACTION
; 
--===========================================================================
--      Exit
--===========================================================================
RAISERROR('===============================================',0,1) WITH NOWAIT;
RAISERROR('RUN COMPLETE',0,1) WITH NOWAIT;
RAISERROR('===============================================',0,1) WITH NOWAIT;
GO

