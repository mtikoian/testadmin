/********************************************************************************************
*********************************************************************************************
	"Stored Procedures Solutions", script version 1.2
	by Jen McCown, Jen@MidnightDBA.com, @MidnightDBA, http://www.MidnightDBA.com/Jen 
	Session downloads and videos: http://www.midnightdba.com/Jen/articles/

		MidnightSQL Consulting - MidnightSQL.com
		When your database needs a hero.

		MinionWare Software - MinionWare.net
		Work like a DBA

********************************************************************************************
********************************************************************************************/


/**************************** SETUP ****************************/
USE master;
GO
IF EXISTS ( SELECT  *
            FROM    sys.databases
            WHERE   name = 'Demo' )
    AND @@servername IN ('YOGACON', 'HIROCON' )
    DROP DATABASE DEMO;
GO

CREATE DATABASE Demo;
go

USE Demo;
GO

CREATE SCHEMA [Audit];
GO


/**************************** INTRO ****************************/
/*
	
	Today's topic: Developing stored procedure solutions.
	This isn't SPs 101, but you'll get a good idea.

	What's an SP? Reusable code, stored in a database.
*/



/**************************** SCENARIO ****************************/
/*
	Our scenario: We want to track database files sizes over time.

	There's more than one solution. What's best? (We're creating a
	recipe, a means to an end.)
*/


/**************************** Step 1: QUESTIONS ****************************/

-- FIRST, ESSENTIAL HOW TO - Where do we even get file size information?
SELECT  *
FROM    sys.master_files;


/*
	Side note: We'll want to change this to sys.database_files in the future; sys.master_files can be inaccurate.
	https://connect.microsoft.com/SQLServer/feedback/details/377223/sys-master-files-does-not-show-accurate-size-information
*/


/*
QnA: Example questions and answers:
	 Do we have an existing solution?

	 Do we need this?

	 Why do we need this? What will it be used for?

	 What else could it be used for?

	 Who will use it? Would anyone else find it useful (if appropriate)?

	 How often might it be used?

	 How big could it get? Scope, size, user base, frequency, number of servers, etc.
		
	 How might it be used?

	 Security concerns? Is this secure data? Who should/n't have access?

	 Where does the solution belong? Examples: Ad hoc SQL, Excel, SP, Powershell, SSRS, Program, elsewhere.

---

Example questions and answers:
	 Do we have an existing solution?
		Nope.

	 Do we need this?
		Yep.

	 Why do we need this? What will it be used for?
		We want to know how much space the DB files are taking up now, and
		what rate of growth they show. Will be useful for disk capacity planning.

	 What else could it be used for?
		We'll see. Maybe spot checking sizes (not just logging over time)...
		Maybe checking for growth anomalies. "Wow, this grew by 50% in January, I wonder why..."

	 Who will use it? Would anyone else find it useful (if appropriate)?
		DBAs mostly. SAN guys might like to have access to that info. Maybe
		some managers too, if they don't have to do anything technical.

	 How often might it be used?
		Gather daily or weekly. Ad hoc as needed, but not more than a handful of
		times per day at most.

	 How big could it get? Scope, size, user base, frequency, number of servers, etc.
		Limited scope and user base. Better include a cleanup mechanism for size.
		Frequency ~wk or mo. Servers, hmm...
		(This definitely affects the design; we can get away with more for smaller
		systems, especially administrative things.)
		
	 How might it be used?
		Automated: schedule, set up alerts and/or reports based on the data.

	 Security concerns?
		Public exposure?
		Limited in-team access?
		PII or other data that needs encrypting?

	 Where does the solution belong? Examples: Ad hoc SQL, Excel, SP, Powershell, SSRS, Program, elsewhere.
		"Tracking" means keeping information over time so we can compare and use it. To us, that means a table.
		Anything that happens repeatedly over time MUST be automated. Simplify your life. That's a job.


**************************** TIME OUT: The Case for SPs ****************************

		-- While some of this may seem obvious, it's important to examine --
		-- our thinking and come up with solid reasons for using SPs.     -- 

	Procedural:	  SPs do stuff (select, modify, insert, generate, set, report, alert, etc.) 
				  As opposed to views, functions.

	Stored:		  Stored in the database. Harder to lose it.

	Contractural: Consistent inputs, consistent outputs. What happens in the middle is obfuscated.
	
	Configurable: Pass in values to get different behavior (say, just one or two DBs insted of all).
				  That simplifies the situation where we might want to track one database at a
				  different interval; instead of copying code to a separate job, just call the same
				  SP with different inputs.
	
	Maintainable: A stored procedure is centrally stored, secure, backed up. It eliminates the need of
				  duplicate code stored all over the place (jobs, dev computers, etc.) For example: 
				  a stored procedure called by 2+ jobs still only needs modification in 1 place; 
				  ad hoc code copied to 2+ jobs must be altered in each job.

	Secure:		  Great for limiting how and what people can do. Lock down all permissions to the DB, but
				  grant permissions

	Small footprint: Tiny network calls. And, we're passing data back and forth to the app unecessarily.
		
*/


/**************************** Step 2: SIMPLEST CASE/POC ****************************/
/*
Simplest case: table, SP, job.
	
*/

SELECT * FROM sys.master_files;

EXEC sp_help "sys.master_files";

-- Copied the specs from sys.master_files:
--DROP TABLE Audit.DBFileSize
CREATE TABLE Audit.DBFileSize
       (
         database_id INT
       , file_id INT
       , file_guid UNIQUEIDENTIFIER
       , type TINYINT
       , type_desc NVARCHAR(120)
       , data_space_id INT
       , name sysname
       , physical_name NVARCHAR(520)
       , state TINYINT
       , state_desc NVARCHAR(4000)
       , size INT
       , max_size INT
       , growth INT
       , is_media_read_only BIT
       , is_read_only BIT
       , is_sparse BIT
       , is_percent_growth BIT
       , is_name_reserved BIT
       , create_lsn NUMERIC(25)
       , drop_lsn NUMERIC(25)
       , read_only_lsn NUMERIC(25)
       , read_write_lsn NUMERIC(25)
       , differential_base_lsn NUMERIC(25)
       , differential_base_guid UNIQUEIDENTIFIER
       , differential_base_time DATETIME
       , redo_start_lsn NUMERIC(25)
       , redo_start_fork_guid UNIQUEIDENTIFIER
       , redo_target_lsn NUMERIC(25)
       , redo_target_fork_guid UNIQUEIDENTIFIER
       , backup_lsn NUMERIC(25)
       , credential_id INT
       );
GO


/*
	--
	PRO TIP: Get used to ending your statements with a semicolon (;). 
			 Useful now, and bets are heavy that it'll eventually be mandatory.
	--
*/


CREATE PROCEDURE AUDIT.GetDBFileSize
/*
	Purpose: Log the current file sizes to the AUDIT.DBFileSize table, 
			 for use in disk space projections.
*/ 
AS
    BEGIN
        INSERT  INTO AUDIT.DBFileSize
                SELECT  *
                FROM    sys.master_files;

    END
GO

EXEC AUDIT.GetDBFileSize;

SELECT * FROM AUDIT.DBFileSize;
GO
--*-- Check out SQL Agent to see our job and weekly schedule: "DBA - Audit DB File Size" --*--


/*
	--
	PRO TIP: You can certainly run a stored procedure without the "EXEC" or
	"EXECUTE", so long as the procedure call is s the first statement in the batch.
	--
	-- Is sys.master_files accurate for tempdb? dbfiles?
*/


--*-- Any problems with this solution so far?


/**************************** Step 3: EVALUATE ****************************/
/**************************** Step 3a: Evaluate the table */

DROP TABLE [Audit].DBFileSize
GO

/*
 Evaluate the table based on need, and on Most Excellent Practices (MEP):
	 Third normal form (3NF)	~=	Primary key, 1 column contains 1 value, 1 row = 1 thing, no duplicate data between rows.
	 Consistency in data meanings
	 Solid naming scheme (consistency, meaning, usability)  
	 Data types (matches the base table if there is one, consistent across the environment ("domain"))
	 NULL-ability
	 Version compatibility - pay attention to data types, other T-SQL rule changes
	 Measurement units (the "size" column here is measured in 8-KB pages, not MB)
	 Too much data? Not enough?

 Discuss: Is it ever okay to break these rules?
 
 (Notice we're not looking at performance, YET.)
*/

CREATE TABLE AUDIT.DBFileSize
    (
      ID INT IDENTITY(1, 1)
             PRIMARY KEY CLUSTERED ,			-- Added a PK. (Cluster seperately in the future.)
      DBName SYSNAME NOT NULL ,		-- ADDED DB name; names and IDs could change over time.
      [database_id] INT NOT NULL ,
      [file_id] INT NOT NULL ,
												-- REMOVED [file_guid]; don't care. (For one thing, master/model/tempdb files don't have a file_guid.)
      [type_desc] NVARCHAR(120) NULL ,			-- Kept [type_desc] instead of [type].
      [data_space_id] INT NOT NULL ,			-- Refers to filegroup. Do we care? Maybe?
      [name] SYSNAME NOT NULL ,
      [physical_name] NVARCHAR(520) NOT NULL ,
      [state_desc] NVARCHAR(120) NULL ,			-- Kept [state_desc] instead of [state].
      [size] INT NOT NULL ,
      [sizeMB] AS ( size * 8 / 1024 )  PERSISTED ,	-- Added a computed, persisted column for file size in MB. 

	  -- FILE GROWTH INFO:
      [max_size] INT NOT NULL ,
      [growth] INT NOT NULL ,
      [is_media_read_only] BIT NOT NULL ,
      [is_read_only] BIT NOT NULL ,
      [is_sparse] BIT NOT NULL ,
      [is_percent_growth] BIT NOT NULL ,

	  [collection_date] DATETIME2  NOT NULL	-- Note that DATETIME2 was introduced in SQL 2008; won't work on 2005 servers.
      
	  -- Dropped [is_name_reserved] and all the LSN data.
    );
GO




/**************************** Step 3b: Evaluate the SP */
/*
 Evaluate the SP based on need, and on Most Excellent Practices (MEP):
	 NEVER EVER use SELECT * in a query, especially not in an SP.
	 ALWAYS use a column list with INSERT statements. Always.
*/


ALTER PROCEDURE AUDIT.GetDBFileSize
/*
	Purpose: Log the current file sizes to the AUDIT.DBFileSize table, 
			 for use in disk space projections.
*/ 
AS
    BEGIN
		DECLARE @BatchDate DATETIME2 = GETDATE();

        INSERT  INTO Audit.DBFileSize
                ( DBName
                , database_id
                , file_id
                , type_desc
                , data_space_id
                , name
                , physical_name
                , state_desc
                , size
                , max_size
                , growth
                , is_media_read_only
                , is_read_only
                , is_sparse
                , is_percent_growth
                , collection_date
                )
                SELECT  d.name AS DBName
                      , m.database_id
                      , m.file_id
                      , m.type_desc
                      , m.data_space_id
                      , m.name
                      , m.physical_name
                      , m.state_desc
                      , m.size
                      , m.max_size
                      , m.growth
                      , m.is_media_read_only
                      , m.is_read_only
                      , m.is_sparse
                      , m.is_percent_growth
                      , @BatchDate AS collection_date
                FROM    sys.master_files AS m
                INNER JOIN sys.databases d
                        ON m.database_id = d.database_id;

    END; 
GO

EXEC AUDIT.GetDBFileSize;

SELECT * FROM AUDIT.DBFileSize;

GO



/**************************** Step 4: EXPAND ****************************/

/*
 Expansions: What about ad hoc? Or, single DB? And what about cleanup?
 Decided: Single SP, instead of multiple for slightly different uses.

 1. Ad hoc use: add a parameter to deal with ad hoc use. 
	Good idea: default behavior should be impermanent (here, not logging data).

		--
		PRO TIP: Limit the input of your SPs, by type (note we used a bit, not 
		an INT or a string type) and/or by programming.

		PRO TIP: Document your SPs! Keep a header, note what parameters are for, etc.
		--
*/


ALTER PROCEDURE AUDIT.GetDBFileSize 
	@log_to_table BIT = 0
	

/*
	Purpose: Log the current file sizes to the AUDIT.DBFileSize table, 
			 for use in disk space projections.

	Parameters:
		@log_to_table		If 0, just returns file size data (for ad hoc use).
							If 1, logs data to "AUDIT.DBFileSize".
		
	Example execution:
		EXEC AUDIT.GetDBFileSize;						-- Ad hoc (non logged), all databases.
		EXEC AUDIT.GetDBFileSize @log_to_table = 1;		-- Logged, all databases.
		
*/
AS 
    BEGIN
		DECLARE @BatchDate DATETIME2 = GETDATE();

        IF @log_to_table = 0 
            SELECT  d.name AS DBName ,
                    m.database_id ,
                    m.file_id ,
                    m.type_desc ,
                    m.data_space_id ,
                    m.name ,
                    m.physical_name ,
                    m.state_desc ,
                    m.size ,
                    m.max_size ,
                    m.growth ,
                    m.is_media_read_only ,
                    m.is_read_only ,
                    m.is_sparse ,
                    m.is_percent_growth,  
					GETDATE() AS collection_date
            FROM    sys.master_files AS m
                    INNER JOIN sys.databases d ON m.database_id = d.database_id;
        ELSE IF @log_to_table = 1
            INSERT  INTO AUDIT.DBFileSize
                    ( DBName ,
                      database_id ,
                      file_id ,
                      type_desc ,
                      data_space_id ,
                      name ,
                      physical_name ,
                      state_desc ,
                      size ,
                      max_size ,
                      growth ,
                      is_media_read_only ,
                      is_read_only ,
                      is_sparse ,
                      is_percent_growth, 
					  collection_date
                    )
                    SELECT  d.name AS DBName ,
                            m.database_id ,
                            m.file_id ,
                            m.type_desc ,
                            m.data_space_id ,
                            m.name ,
                            m.physical_name ,
                            m.state_desc ,
                            m.size ,
                            m.max_size ,
                            m.growth ,
                            m.is_media_read_only ,
                            m.is_read_only ,
                            m.is_sparse ,
                            m.is_percent_growth,
							@BatchDate AS collection_date
                    FROM    sys.master_files AS m
                            INNER JOIN sys.databases d ON m.database_id = d.database_id;

	
    END
GO

/*
 2. Option for single DB. Add a parameter.

		--
		PRO TIP: Parameter / variable lengths can be tricky. Think expansively, and long term.
		--

*/

ALTER PROCEDURE AUDIT.GetDBFileSize 
	@log_to_table BIT = 0 ,
	@database_filter sysname = '%'
/*
	Purpose: Log the current file sizes to the AUDIT.DBFileSize table, 
			 for use in disk space projections.

	Parameters:
		@log_to_table		If 0, just returns file size data (for ad hoc use).
							If 1, logs data to "AUDIT.DBFileSize".
		
		@database_filter	Filters the database data to retrieve.  Defaults to all ('%'). 

		
	Example execution:
		EXEC AUDIT.GetDBFileSize;						-- Ad hoc (non logged), all databases.
		EXEC AUDIT.GetDBFileSize @log_to_table = 1;		-- Logged, all databases.
		EXEC AUDIT.GetDBFileSize @log_to_table = 0, 
								 @database_filter = 'Minion';	-- Nonlogged, all "Adventure*" databases.

*/
AS 
    BEGIN
        IF @log_to_table = 0 
            SELECT  d.name AS DBName ,
                    m.database_id ,
                    m.file_id ,
                    m.type_desc ,
                    m.data_space_id ,
                    m.name ,
                    m.physical_name ,
                    m.state_desc ,
                    m.size ,
                    m.max_size ,
                    m.growth ,
                    m.is_media_read_only ,
                    m.is_read_only ,
                    m.is_sparse ,
                    m.is_percent_growth
					, GETDATE() AS collection_date
            FROM    sys.master_files AS m
                    INNER JOIN sys.databases d ON m.database_id = d.database_id
			WHERE d.NAME LIKE @database_filter; 
        ELSE 
            INSERT  INTO AUDIT.DBFileSize
                    ( DBName ,
                      database_id ,
                      file_id ,
                      type_desc ,
                      data_space_id ,
                      name ,
                      physical_name ,
                      state_desc ,
                      size ,
                      max_size ,
                      growth ,
                      is_media_read_only ,
                      is_read_only ,
                      is_sparse ,
                      is_percent_growth, 
					  collection_date
                    )
                    SELECT  d.name AS DBName ,
                            m.database_id ,
                            m.file_id ,
                            m.type_desc ,
                            m.data_space_id ,
                            m.name ,
                            m.physical_name ,
                            m.state_desc ,
                            m.size ,
                            m.max_size ,
                            m.growth ,
                            m.is_media_read_only ,
                            m.is_read_only ,
                            m.is_sparse ,
                            m.is_percent_growth,
							GETDATE() AS collection_date
                    FROM    sys.master_files AS m
                            INNER JOIN sys.databases d ON m.database_id = d.database_id
					WHERE d.NAME LIKE @database_filter;

    END
GO

/**************************** Exploring options: Table Valued Parameters */
-- You do have the option to read in a comma delimited list of values, parse and use them; 
-- or, a table valued parameter (SQL 2008 +, requires a custom type).

CREATE TYPE dbo.DBlist AS TABLE 
( NAME SYSNAME );  -- Change this to DBName
GO

CREATE PROCEDURE AUDIT.GetDBFileSize_TVPexample
    @log_to_table BIT = 0 ,
    @database_filter DBlist READONLY
/*
	Purpose: Log the current file sizes to the AUDIT.DBFileSize table, 
			 for use in disk space projections.

	Parameters:
		@log_to_table		If 0, just returns file size data (for ad hoc use).
							If 1, logs data to "AUDIT.DBFileSize".
		
		@database_filter	Defaults to all ('%'). 

	Example execution:
		-- Ad hoc (non logged), AdventureWorks database.
		DECLARE @dblist DBlist;

		INSERT  INTO @dblist
				( name )
		VALUES  ( 'AdventureWorks'), ('master'), ('Demo' );

		EXEC AUDIT.GetDBFileSize_TVPexample @log_to_table = 0, @database_filter = @dblist;

	Discussion:
		This procedure doesn't currently have a default way to pull back all databases;
		it is hard limited to whatever is passed in via the table variable. Discuss: How
		might we resolve this? Do we want to? It really depends on how this is to be used.

*/
AS 
    BEGIN
        IF @log_to_table = 0 
            SELECT  d.name AS DBName ,
                    m.database_id ,
                    m.file_id ,
                    m.type_desc ,
                    m.data_space_id ,
                    m.name ,
                    m.physical_name ,
                    m.state_desc ,
                    m.size ,
                    m.max_size ,
                    m.growth ,
                    m.is_media_read_only ,
                    m.is_read_only ,
                    m.is_sparse ,
                    m.is_percent_growth
					, GETDATE() AS collection_date
            FROM    sys.master_files AS m
                    INNER JOIN sys.databases d ON m.database_id = d.database_id
                    INNER JOIN @database_filter db ON db.NAME = d.name;
        ELSE  IF @log_to_table = 1
            INSERT  INTO AUDIT.DBFileSize
                    ( DBName ,
                      database_id ,
                      file_id ,
                      type_desc ,
                      data_space_id ,
                      name ,
                      physical_name ,
                      state_desc ,
                      size ,
                      max_size ,
                      growth ,
                      is_media_read_only ,
                      is_read_only ,
                      is_sparse ,
                      is_percent_growth,  collection_date
                    )
                    SELECT  d.name AS DBName ,
                            m.database_id ,
                            m.file_id ,
                            m.type_desc ,
                            m.data_space_id ,
                            m.name ,
                            m.physical_name ,
                            m.state_desc ,
                            m.size ,
                            m.max_size ,
                            m.growth ,
                            m.is_media_read_only ,
                            m.is_read_only ,
                            m.is_sparse ,
                            m.is_percent_growth, GETDATE() AS collection_date
                    FROM    sys.master_files AS m
                            INNER JOIN sys.databases d ON m.database_id = d.database_id
                            INNER JOIN @database_filter db ON db.NAME = d.name;

    END
GO

---- Run with values:
DECLARE @dblist DBlist;

INSERT  INTO @dblist
        ( name )
VALUES  ( 'master' ),
        ( 'msdb' ),
        ( 'model' );

EXEC AUDIT.GetDBFileSize_TVPexample @log_to_table = 0, @database_filter = @dblist;

GO
---- Run without values (returns nothing): 
DECLARE @dblist DBlist;

EXEC AUDIT.GetDBFileSize_TVPexample @log_to_table = 0, @database_filter = @dblist;
GO



/*
 3. Cleanup! Add a parameter for retention length.

	-- 
	PRO TIP: Test potentially confusing code a few different ways.
	--
*/

ALTER PROCEDURE AUDIT.GetDBFileSize 
	@log_to_table BIT = 0 ,
	@database_filter NVARCHAR(257) = '%', 
	@retention_days SMALLINT = 730
/*
	Purpose: Log the current file sizes to the AUDIT.DBFileSize table, 
			 for use in disk space projections.

	Parameters:
		@log_to_table		If 0, just returns file size data (for ad hoc use).
							If 1, logs data to "AUDIT.DBFileSize".
		
		@database_filter	Filters the database data to retrieve.  Defaults to all ('%'). 

		@retention_days		Days to retain data in the AUDIT.DBFileSize table. Default is 2 years (730 days).

	Example execution:
		EXEC AUDIT.GetDBFileSize;						-- Ad hoc (non logged), all databases.
		EXEC AUDIT.GetDBFileSize @log_to_table = 1;		-- Logged, all databases.
		EXEC AUDIT.GetDBFileSize @log_to_table = 1, 
								 @database_filter = 'Adventure%', 
								 @retention_days=365;	-- Logged, all "Adventure*" databases.
*/
AS 
    BEGIN
        IF @log_to_table = 0 
            SELECT  d.name AS DBName ,
                    m.database_id ,
                    m.file_id ,
                    m.type_desc ,
                    m.data_space_id ,
                    m.name ,
                    m.physical_name ,
                    m.state_desc ,
                    m.size ,
                    m.max_size ,
                    m.growth ,
                    m.is_media_read_only ,
                    m.is_read_only ,
                    m.is_sparse ,
                    m.is_percent_growth
					, GETDATE() AS collection_date
            FROM    sys.master_files AS m
                    INNER JOIN sys.databases d ON m.database_id = d.database_id
			WHERE d.NAME LIKE @database_filter;
        ELSE  IF @log_to_table = 1
            INSERT  INTO AUDIT.DBFileSize
                    ( DBName ,
                      database_id ,
                      file_id ,
                      type_desc ,
                      data_space_id ,
                      name ,
                      physical_name ,
                      state_desc ,
                      size ,
                      max_size ,
                      growth ,
                      is_media_read_only ,
                      is_read_only ,
                      is_sparse ,
                      is_percent_growth
					  , collection_date
                    )
                    SELECT  d.name AS DBName ,
                            m.database_id ,
                            m.file_id ,
                            m.type_desc ,
                            m.data_space_id ,
                            m.name ,
                            m.physical_name ,
                            m.state_desc ,
                            m.size ,
                            m.max_size ,
                            m.growth ,
                            m.is_media_read_only ,
                            m.is_read_only ,
                            m.is_sparse ,
                            m.is_percent_growth, GETDATE() AS collection_date
                    FROM    sys.master_files AS m
                            INNER JOIN sys.databases d ON m.database_id = d.database_id
					WHERE d.NAME LIKE @database_filter;

        DELETE  FROM AUDIT.DBFileSize
        WHERE   collection_date < DATEADD(DAY, -1 * @retention_days, GETDATE());
		
    END
GO



/*
**************************** TIME OUT: Working out complex ideas ****************************
Here was our end result:
        DELETE  FROM AUDIT.DBFileSize
        WHERE   collection_date < DATEADD(DAY, -1 * @retention_days, GETDATE());

But how did we get there? And how do we verify it?

Plain English goal: 
	Delete data older than N days ago.

Sophisticate this toward code: 
	Delete data older than the date N days ago. (E.g.: delete data older than the date 10 days ago.)
			
	Delete WHERE collection_date is older than the date N days ago.
	
	Delete WHERE collection_date is older than (today's date - N days).
	
	Delete WHERE collection_date < (today's date - N days).  [Note: 1/10/2016 is LESS THAN 1/20/2016.]
	
	Delete WHERE collection_date < DATEADD(DAY, -N days, GetDate())
	
	Delete WHERE collection_date < DATEADD(DAY, -1 * @retention_days, GetDate())

*/

/**************************** TIME OUT: Testing solutions ****************************

 Figure out and test the code:
	 I want to delete WHERE the collection_date is farther back from (today minus retention days)
	  =>
	 Delete WHERE collection_date < (today minus retention days)
	  =>
	 WHERE collection_date < GetDate() - @retention_days; -- this is legal, but less explicit visually. Arguable.
	  =>
	 WHERE collection_date < DATEADD(DAY, -1 * @retention_days, GetDate());
*/	
	---- SETUP ---- 
  

        INSERT  INTO AUDIT.DBFileSize
                ( collection_date,
					DBName ,
                    database_id ,
                    file_id ,
                    type_desc ,
                    data_space_id ,
                    name ,
                    physical_name ,
                    state_desc ,
                    size ,
                    max_size ,
                    growth ,
                    is_media_read_only ,
                    is_read_only ,
                    is_sparse ,
                    is_percent_growth
                )
                SELECT  DATEADD(DAY, -60, GETDATE()) AS collection_date,
						d.name AS DBName ,
                        m.database_id ,
                        m.file_id ,
                        m.type_desc ,
                        m.data_space_id ,
                        m.name ,
                        m.physical_name ,
                        m.state_desc ,
                        m.size ,
                        m.max_size ,
                        m.growth ,
                        m.is_media_read_only ,
                        m.is_read_only ,
                        m.is_sparse ,
                        m.is_percent_growth
                FROM    sys.master_files AS m
                        INNER JOIN sys.databases d ON m.database_id = d.database_id;
       INSERT  INTO AUDIT.DBFileSize
                    ( collection_date,
						DBName ,
                      database_id ,
                      file_id ,
                      type_desc ,
                      data_space_id ,
                      name ,
                      physical_name ,
                      state_desc ,
                      size ,
                      max_size ,
                      growth ,
                      is_media_read_only ,
                      is_read_only ,
                      is_sparse ,
                      is_percent_growth
                    )
                    SELECT  DATEADD(DAY, -60, GETDATE()) AS collection_date,
							d.name AS DBName ,
                            m.database_id ,
                            m.file_id ,
                            m.type_desc ,
                            m.data_space_id ,
                            m.name ,
                            m.physical_name ,
                            m.state_desc ,
                            m.size ,
                            m.max_size ,
                            m.growth ,
                            m.is_media_read_only ,
                            m.is_read_only ,
                            m.is_sparse ,
                            m.is_percent_growth
                    FROM    sys.master_files AS m
                            INNER JOIN sys.databases d ON m.database_id = d.database_id;


	---- TESTING ---- 
	DECLARE @example_collection_date DATETIME;
	DECLARE @retention_days SMALLINT;
	SET @retention_days = 35;

        SELECT  DISTINCT 
				collection_date ,
                @retention_days AS retention_days ,
                DATEADD(DAY, -1 * @retention_days, GETDATE()) AS retention_date
        FROM    Audit.DBFileSize
        WHERE   collection_date < DATEADD(DAY, -1 * @retention_days, GETDATE());

	/* Test! Check to see if you get the right results back for 1 day, 15 days, 45 days. */
	/*
		Remember what we're asking here: the data selected here is what we want to be deleted.
		Are the dates that show up OLDER than N days ago? Yes? Then it passes! Our logic is perfect!
	
	*/

SELECT COUNT(*) FROM Audit.DBFileSize;

EXEC AUDIT.GetDBFileSize @log_to_table = 0, @retention_days = 100; -- Should delete nothing
SELECT COUNT(*) FROM Audit.DBFileSize;

EXEC AUDIT.GetDBFileSize @log_to_table = 0, @retention_days = 45; -- Should delete the oldest batch;
SELECT COUNT(*) FROM Audit.DBFileSize;

EXEC AUDIT.GetDBFileSize @log_to_table = 0, @retention_days = 15; -- Should delete the second oldest batch.
SELECT COUNT(*) FROM Audit.DBFileSize;


/**************************** Step 5: EVALUATE FOR PERFORMANCE ****************************/
/*
 Performance is a HUGE topic, so go read many books. 
 BUT, there are some Most Excellent Practices:
	
	Everything we've said: 3NF for tables, consistency, etc.
	Avoid cursors
	Avoid query hints
	Test your code with realistic data; examine query plans (Grant Fritchey's books)
	Index appropriately
	Watch for parameter sniffing

	(Breaking rules)
*/


/**************************** Step N: ...AND MORE AND MORE ****************************/
/*
Additional topics (maybe part 2):
	 Error handling
	 Expansion: File space usage 
	 Code review
	 More testing
	 Dynamic T-SQL
	 Whether to break up big SPs into multiple SPs

	 Multi server coding! - How? You'll need to come to our Enterprise Management session!

*/



/********************************************************************************************
*********************************************************************************************
This session, recording and materials are licensed under a Creative Commons Attribution-
Noncommercial-No Derivative Works 3.0 United States License.
********************************************************************************************
********************************************************************************************/