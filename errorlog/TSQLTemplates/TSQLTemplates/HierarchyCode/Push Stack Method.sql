--===========================================================================
--      Presets
--===========================================================================
--===== We're going to be dropping tables so do this inn a nice, safe place
     -- that everyone has.
    USE tempdb;

--===== Build the Employee table out to the desired size. Just change the
     -- "1000" to the number of rows you want to work with.
   EXEC dbo.BuildTestHierarchy 1000;

--===== Since we're going to be using loops, supress the auto-display of 
     -- row counts to improve performance... a LOT!
    SET NOCOUNT ON;

--===== Conditionally drop the tables involved
     IF OBJECT_ID('tempdb..#EmployeeCopy','U') IS NOT NULL
        DROP TABLE #EmployeeCopy
;
     IF OBJECT_ID('tempdb.dbo.NestedSets','U') IS NOT NULL
        DROP TABLE tempdb.dbo.NestedSets
;
--===== Start a duration timer (need to do measure time this way because of
     -- the loops)
DECLARE @StartTime DATETIME;
 SELECT @StartTime = GETDATE();

--===========================================================================
--      Create a copy of the existing Employee table and populate it.
--===========================================================================
--===== Create and populate the sacrificial table on the fly.
     -- Note that the contents of this table will be destroyed!
--===== Populate the copy of the Employee table
 SELECT EmployeeID, ManagerID
   INTO #EmployeeCopy
   FROM dbo.Employee
;
--===== Add a critical index that was left out of the original code.
 CREATE UNIQUE CLUSTERED INDEX By_ManagerID_EmployeeID
     ON #EmployeeCopy (ManagerID, EmployeeID)
;
        RAISERROR('Table copied. Building Nested Sets.',0,1) WITH NOWAIT
--===========================================================================
--      Create a table to hold the final Nested Sets hierarchy in.
--===========================================================================
--===== Create the "stack" table. This ends up being the final table which
     -- will contain the Nested Sets hierarchy.
 CREATE TABLE dbo.NestedSets 
        (
        StackTop   INT NOT NULL,
        EmployeeID INT NOT NULL,
        LeftBower  INT,
        RightBower INT
        )
;
--===== Add a critical index that was left out of the original code.
 CREATE UNIQUE CLUSTERED INDEX By_EmployeeID_StackTop
     ON dbo.NestedSets  (EmployeeID, StackTop)
;
--===========================================================================
--      Build the nested sets.
--===========================================================================
--===== Declare some variables to conntrol the loop
DECLARE @BowerCounter INT,
        @MaxBower INT,
        @CurrentTop INT
;
--===== Preset the variables to a known starting point
 SELECT @BowerCounter = 2,  --2 because we'll preload the first bower
        @MaxBower     = 2 * (SELECT COUNT(*) FROM #EmployeeCopy),
        @CurrentTop   = 1
;
--===== Preload the Root Node with it's Bowers which we already know
 INSERT INTO dbo.NestedSets
        (StackTop, EmployeeID, LeftBower, RightBower)
 SELECT 1,         EmployeeID, 1,         @MaxBower 
   FROM #EmployeeCopy
  WHERE ManagerID IS NULL --Identifies the root Node
;
--===== Delete the node we just loaded so we don't pull it again.
 DELETE 
   FROM #EmployeeCopy
  WHERE ManagerID IS NULL
;
--===== Use some RBAR on steroids to load the other nodes and mark them with
     -- the correct Bower numbers
  WHILE @BowerCounter < @MaxBower --Already loaded the max Bower in Root Node
     IF EXISTS (
                SELECT 1 
                  FROM dbo.NestedSets  AS stack 
                  JOIN #EmployeeCopy   AS copy
                    ON stack.EmployeeID = copy.ManagerID
                   AND stack.StackTop   = @CurrentTop
               )
  BEGIN --===== Push when top has subordinates and set LeftBower value
         INSERT INTO dbo.NestedSets
                (StackTop, EmployeeID, LeftBower, RightBower)
         SELECT (@CurrentTop + 1), MIN(copy.EmployeeID), @BowerCounter, NULL
           FROM dbo.NestedSets AS stack
           JOIN #EmployeeCopy AS copy
             ON stack.EmployeeID = copy.ManagerID
            AND stack.StackTop   = @CurrentTop
        ;
         DELETE FROM #EmployeeCopy
          WHERE EmployeeID = (SELECT EmployeeID
                                FROM dbo.NestedSets
                               WHERE StackTop = @CurrentTop + 1)
        ;
         SELECT @BowerCounter = @BowerCounter + 1,
                @CurrentTop   = @CurrentTop + 1
        ;
        IF @BowerCounter%10000 = 0
        RAISERROR('@BowerCounter = %u',0,1,@BowerCounter) WITH NOWAIT;
        ;
    END
   ELSE 
  BEGIN --===== Pop the stack and set RightBower value
         UPDATE dbo.NestedSets
            SET RightBower = @BowerCounter,
                StackTop   = -StackTop -- pops the stack
          WHERE StackTop   = @CurrentTop
        ;
         SELECT @BowerCounter = @BowerCounter + 1,
                @CurrentTop   = @CurrentTop - 1
        ;
        IF @BowerCounter%10000 = 0
        RAISERROR('@BowerCounter = %u',0,1,@BowerCounter) WITH NOWAIT
        ;
    END;
--===========================================================================
--      Report the duration and Exit
--===========================================================================
RAISERROR('===============================================',0,1) WITH NOWAIT;
    PRINT 'Duration = ' + CONVERT(CHAR(12),GETDATE()-@StartTime,114)
RAISERROR('RUN COMPLETE',0,1) WITH NOWAIT;
RAISERROR('===============================================',0,1) WITH NOWAIT;
GO
-- SELECT * FROM dbo.NestedSets ORDER BY LeftBower
