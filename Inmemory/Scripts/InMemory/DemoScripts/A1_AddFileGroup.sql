
/**********************************************************************************************
 
 Notes: Add MEMORY_OPTIMIZED_DATA filegroup and container to enable in-memory OLTP in the database 
		This code can be used to alter other existing databases.

 **********************************************************************************************/

:setvar DBName "AdventureWorks2014"
:setvar CheckPointDir "C:\SQLSaturday\2015\SQLSat379\DATA\"

-- Create FILEGROUP
-- Can only have one memory optimized filegroup per database
IF NOT EXISTS (SELECT * FROM $(DBName).sys.data_spaces WHERE type='FX') --< InMemory abbreviationI
	ALTER DATABASE $(DBName) 
	  ADD FILEGROUP [$(DBName)_mem] CONTAINS MEMORY_OPTIMIZED_DATA  --< *** This is where all the magic happens ***
GO

-- Create New File and add it to the new Filegroup
-- You can have multiple containers (files) per memory optimized filegroup
-- Advantage of multiple containers is for recovery purposes; When the database is recovering, it can
-- multi-thread the recover of objects back into memory
IF NOT EXISTS (SELECT * FROM $(DBName).sys.data_spaces ds 
						JOIN $(DBName).sys.database_files df ON 
							 ds.data_space_id=df.data_space_id WHERE ds.type='FX') --< InMemory abbreviation
	ALTER DATABASE $(DBName)
	  ADD FILE (name='$(DBName)_mem', filename='$(CheckPointDir)$(DBName)_mem') 
	  TO FILEGROUP [$(DBName)_mem]
GO

-- Navigate to file directory to see new files created

-- C:\SQLSaturday\2015\Jacksonville\DATA

-- Take a look at the properties of the database via SSMS

/*
-- Take a look as the filegroup properties via system view

 SELECT Name, Type, Type_Desc 
   FROM AdventureWorks2014.sys.data_spaces 
  WHERE type='FX' --< InMemory abbreviation

*/