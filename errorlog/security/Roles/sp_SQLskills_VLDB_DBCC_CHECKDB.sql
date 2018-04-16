

/************************************************************
When procedure executed for first time it will perform DBCC checks only 
on that database 


************************************************************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE dbo.sp_SQLskills_VLDB_DBCC_CHECKDB
(      
       @day_of_week INT = NULL,
       @stop_time DATETIME = '5:00',
       @debug_flag BIT = 0
)
AS

     
SET NOCOUNT ON
BEGIN
       -- Initialize the @day_of_week parameter if it is NULL;
	IF @day_of_week IS NULL
		SET @day_of_week = DATEPART(dw, GETDATE());
             
		-- Initialize the @stop_time paramter for the current day;
		SELECT @stop_time = 
			-- Add Minutes
			DATEADD(mi, DATEPART(mi, @stop_time), 
				-- Add Hours
				DATEADD(hh, DATEPART(hh, @stop_time), 
					-- Trim the time from current timestamp to get just todays date!
					DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)
						)
					)

	--If stop time is before the current time, set stop time for the next day
	IF @stop_time < CURRENT_TIMESTAMP
    SET @stop_time = DATEADD(dd, 1, @stop_time);

	-- Setup execution tracking table if it doesn't already exist
	IF OBJECT_ID('msdb.dbo.SQLSkills_VLDB_DBCC_Tracker') IS NULL
	BEGIN
		CREATE TABLE [msdb].[dbo].[SQLSkills_VLDB_DBCC_Tracker] (      
			[database_id] INT, 
			[object_id] INT, 
			[last_page_count] BIGINT, 
			[last_check_date] DATETIME, 
			[last_duration_seconds] INT,
			[parity_bit] BIT
			);
    END    
       
       -- Setup configuration table if it doesn't already exist
    IF OBJECT_ID('msdb.dbo.SQLSkills_VLDB_DBCC_Config') IS NULL
    BEGIN
        CREATE TABLE [msdb].[dbo].[SQLSkills_VLDB_DBCC_Config] (      
			[database_id] INT PRIMARY KEY, 
			[last_object_id] INT, 
			[last_completion_date] DATETIME, 
			[current_parity_bit] BIT
			); 
    END    

    -- Setup error tracking table if it doesn't already exist
    IF OBJECT_ID('msdb.dbo.SQLskills_DBCC_CHECKDB_output') IS NULL
    BEGIN 
        CREATE TABLE [msdb].[dbo].[SQLskills_DBCC_CHECKDB_output] (
			[DateCheckOccurred] [DATETIME] DEFAULT(CURRENT_TIMESTAMP) NOT NULL,
			[CheckSQLCmd] [varchar](256) NOT NULL,
			[Error] [INT] NULL,
			[Level] [INT] NULL,
			[State] [INT] NULL,
			[MessageText] [NVARCHAR](2048) NULL,
			[RepairLevel] [NVARCHAR](22) NULL,
			[Status] [INT] NULL,
			[DbId] [INT] NULL,
			[ObjectId] [INT] NULL,
			[IndexId] [INT] NULL,
			[PartitionId] [BIGINT] NULL,
			[AllocUnitId] [BIGINT] NULL,
			[File] [SMALLINT] NULL,
			[Page] [INT] NULL,
			[Slot] [INT] NULL,
			[RefFile] [SMALLINT] NULL,
			[RefPage] [INT] NULL,
			[RefSlot] [INT] NULL,
			[Allocation] [SMALLINT] NULL
			);
	END
       
    -- Temp table for catching errors
    CREATE TABLE #SQLskills_DBCC_CHECKDB_output (
		[Error] [INT] NULL,
		[Level] [INT] NULL,
		[State] [INT] NULL,
		[MessageText] [NVARCHAR](2048) NULL,
		[RepairLevel] [NVARCHAR](22) NULL,
		[Status] [INT] NULL,
		[DbId] [INT] NULL,
		[ObjectId] [INT] NULL,
		[IndexId] [INT] NULL,
		[PartitionId] [BIGINT] NULL,
		[AllocUnitId] [BIGINT] NULL,
		[File] [SMALLINT] NULL,
		[Page] [INT] NULL,
		[Slot] [INT] NULL,
		[RefFile] [SMALLINT] NULL,
		[RefPage] [INT] NULL,
		[RefSlot] [INT] NULL,
		[Allocation] [SMALLINT] NULL
		);
       

    DECLARE @sqlcmd VARCHAR(256);
    DECLARE @current_rowid INT;
    DECLARE @current_object_id INT;
    DECLARE @starttime DATETIME;
    DECLARE @runtime INT;
    DECLARE @total_pages INT;
    DECLARE @daily_target_pages INT;
    DECLARE @current_parity_bit BIT;
       
    IF NOT EXISTS (SELECT 1
					FROM [msdb].[dbo].[SQLSkills_VLDB_DBCC_Config]
					WHERE [database_id] = DB_ID())
    BEGIN
		INSERT INTO [msdb].[dbo].[SQLSkills_VLDB_DBCC_Config]
			([database_id], [last_object_id], [last_completion_date], [current_parity_bit])
            VALUES (DB_ID(), NULL, NULL, 0);
    END
       
    -- Get the current parity BIT for the current database
    SELECT @current_parity_bit = current_parity_bit
    FROM [msdb].[dbo].[SQLSkills_VLDB_DBCC_Config]
    WHERE [database_id] = DB_ID();

       -- Check if parity change needs to occur excluding tables that haven't been checked before
    IF NOT EXISTS (      
		SELECT 1
        FROM [sys].[allocation_units] [au]
        JOIN [sys].[partitions] [p]
                ON [au].[container_id] = [p].[partition_id]
        JOIN [sys].[objects] [o]
                ON [p].[object_id] = [o].[object_id]
        LEFT JOIN [msdb].[dbo].[SQLSkills_VLDB_DBCC_Tracker] [t]
                    ON [o].[object_id] = [t].[object_id]
                    AND DB_ID() = [t].[database_id]
        WHERE ([t].[parity_bit] IS NOT NULL 
            AND [t].[parity_bit] <> @current_parity_bit))
		BEGIN
			SET @current_parity_bit = CASE 
				WHEN @current_parity_bit = 1 THEN 0
				ELSE 1
			END;
		END
              
    -- Create a work table to hold the tables for the current day
    DECLARE @WorkTable TABLE (
		[RowID] INT IDENTITY PRIMARY KEY, 
		[object_id] INT, 
		[total_pages] BIGINT
		);

	-- CHECKALLOC and CHECKCATALOG run on Day 1 of the week
	IF @day_of_week = 1 
	BEGIN
        -- Setup the command to execute
        SET @sqlcmd = 'DBCC CHECKALLOC WITH ALL_ERRORMSGS, NO_INFOMSGS, TABLERESULTS';
		print (@sqlcmd)
        IF @debug_flag = 1
            PRINT 'DEBUG: Running ' + @sqlcmd;
        ELSE
        BEGIN
			-- Execute the command and write any errors in the output to a temp table
			INSERT INTO #SQLskills_DBCC_CHECKDB_output
			EXECUTE(@sqlcmd);
            
			-- Insert any errors in the output temp table into the tracking table
			INSERT INTO msdb.dbo.SQLskills_DBCC_CHECKDB_output (
				[DateCheckOccurred], 
				[CheckSQLCmd], 
				[Error], 
				[Level], 
				[State], 
				[MessageText], 
				[RepairLevel], 
				[Status], 
				[DbId], 
				[ObjectId], 
				[IndexId], 
				[PartitionId], 
				[AllocUnitId], 
				[File], 
				[Page], 
				[Slot], 
				[RefFile], 
				[RefPage], 
				[RefSlot], 
				[Allocation])
			SELECT CURRENT_TIMESTAMP, 
				@sqlcmd, 
				[Error], 
				[Level], 
				[State], 
				[MessageText], 
				[RepairLevel], 
				[Status], 
				[DbId], 
				[ObjectId], 
				[IndexId], 
				[PartitionId], 
				[AllocUnitId], 
				[File], 
				[Page], 
				[Slot], 
				[RefFile], 
				[RefPage], 
				[RefSlot], 
				[Allocation]
			FROM #SQLskills_DBCC_CHECKDB_output;
            
            -- Clear the temp table for reuse
            TRUNCATE TABLE #SQLskills_DBCC_CHECKDB_output;

        END
        
        IF @debug_flag = 1
            PRINT 'DEBUG: Running DBCC CHECKCATALOG'
        ELSE
            DBCC CHECKCATALOG WITH NO_INFOMSGS;
    END  
       
    -- Insert the object_id's to be checked for this parity_bit rotation in the worktable
    INSERT INTO @WorkTable (
		[object_id], 
		[total_pages]
		)
    SELECT
        [o].[object_id] [object_id],
        SUM([au].[total_pages]) [total_pages]
    FROM [sys].[allocation_units] [au]
    JOIN [sys].[partitions] [p]
        ON [au].[container_id] = [p].[partition_id]
    JOIN [sys].[objects] AS [o]
        ON [p].[object_id] = [o].[object_id]
    LEFT JOIN [msdb].[dbo].[SQLSkills_VLDB_DBCC_Tracker] [t]
        ON [o].[object_id] = [t].[object_id]
			AND DB_ID() = [t].[database_id]
    WHERE (
		[t].[parity_bit] IS NULL 
        OR [t].[parity_bit] <> @current_parity_bit
		)
    GROUP BY [o].[object_id]
    ORDER BY SUM([au].[total_pages]) ASC;


    -- Get the first object in the current days bucket
    SELECT @current_rowid=MIN([RowID])
    FROM @WorkTable;
       
    WHILE @current_rowid IS NOT NULL
		AND CURRENT_TIMESTAMP < @stop_time
    BEGIN
		-- Get the total_pages for the current object_id
		SELECT 
			@current_object_id = [object_id],
			@total_pages = [total_pages]
		FROM @WorkTable
		WHERE [RowID] = @current_rowid;
              
		-- Reset the starttime for tracking runtime duration
		SET @starttime = CURRENT_TIMESTAMP;
              
		-- Setup the command to execute
		SET @sqlcmd = 'DBCC CHECKTABLE(' + CAST(@current_object_id AS varchar) + ') WITH ALL_ERRORMSGS, NO_INFOMSGS, TABLERESULTS;'
              
		IF @debug_flag = 1
			PRINT 'DEBUG: Running ' + @sqlcmd;
    ELSE
		BEGIN
			-- Execute the command and write any errors in the output to a temp table
			INSERT INTO #SQLskills_DBCC_CHECKDB_output
			EXECUTE(@sqlcmd);
            
			-- Insert any errors in the output temp table into the tracking table
			INSERT INTO [msdb].[dbo].[SQLskills_DBCC_CHECKDB_output] (
				[DateCheckOccurred], 
				[CheckSQLCmd], 
				[Error], 
				[Level], 
				[State], 
				[MessageText], 
				[RepairLevel], 
				[Status], 
				[DbId], 
				[ObjectId], 
				[IndexId], 
				[PartitionId], 
				[AllocUnitId], 
				[File], 
				[Page], 
				[Slot], 
				[RefFile], 
				[RefPage], 
				[RefSlot], 
				[Allocation]
				)
			SELECT 
				CURRENT_TIMESTAMP, 
				@sqlcmd, 
				[Error], 
				[Level], 
				[State], 
				[MessageText], 
				[RepairLevel], 
				[Status], 
				[DbId], 
				[ObjectId], 
				[IndexId], 
				[PartitionId], 
				[AllocUnitId], 
				[File], 
				[Page], 
				[Slot], 
				[RefFile], 
				[RefPage], 
				[RefSlot], 
				[Allocation]
			FROM #SQLskills_DBCC_CHECKDB_output;
            
			-- Clear the temp table for reuse
			TRUNCATE TABLE #SQLskills_DBCC_CHECKDB_output;

		END
              
		-- Calculate the runtime duration
		SELECT @runtime = DATEDIFF(ss, @starttime, CURRENT_TIMESTAMP);
              
		-- Update tracking table with check information for this object_id
		-- Insert a new record for the object_id if one doesn't exist
		IF EXISTS (
			SELECT 1 FROM msdb.dbo.SQLSkills_VLDB_DBCC_Tracker
			WHERE database_id = DB_ID()
			AND object_id = @current_object_id)
		BEGIN
			UPDATE [msdb].[dbo].[SQLSkills_VLDB_DBCC_Tracker]
			SET [last_check_date] = @starttime,
				[last_duration_seconds] = @runtime,
				[last_page_count] = @total_pages,
				[parity_bit] = @current_parity_bit
			WHERE [object_id] = @current_object_id
			AND [database_id] = DB_ID();
		END
		ELSE
		BEGIN
			INSERT INTO [msdb].[dbo].[SQLSkills_VLDB_DBCC_Tracker] (
				[database_id], 
				[object_id],
				[last_check_date], 
				[last_duration_seconds], 
				[last_page_count], 
				[parity_bit]
				)
			VALUES (DB_ID(), @current_object_id, @starttime, @runtime, @total_pages, @current_parity_bit);
		END            
		-- UPDATE the configuration table
		UPDATE [msdb].[dbo].[SQLSkills_VLDB_DBCC_Config]
		SET	[last_object_id] = @current_object_id,
			[last_completion_date] = CURRENT_TIMESTAMP,
			[current_parity_bit] = @current_parity_bit
		WHERE [database_id] = DB_ID();
              
		IF @stop_time < CURRENT_TIMESTAMP
		BEGIN
			PRINT ('Terminating due to @stop_time parameter')
		END
		ELSE
		BEGIN     
			-- Get the next object_id in the work table and loop if it isn't NULL
			SELECT @current_rowid=MIN([RowID])
			FROM @WorkTable
			WHERE RowID > @current_rowid;
		END
          	    
	END

	DROP TABLE #SQLskills_DBCC_CHECKDB_output;

END