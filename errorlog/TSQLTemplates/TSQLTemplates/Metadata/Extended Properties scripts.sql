-- BEGIN TRAN


-- Schema
SELECT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@name = N''Description'', @value = N'''''
FROM sys.schemas SCH
WHERE principal_id = 1

-- Tables
SELECT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id

-- Columns
SELECT TOP (100) PERCENT
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''COLUMN'', @level2name = [' + COL.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.columns COL
 ON TBL.object_id = COL.object_id
ORDER BY SCH.name, TBL.name, COL.column_id

-- Unique key constraints
SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''CONSTRAINT'', @level2name = [' + SKC.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.key_constraints SKC
 ON TBL.object_id = SKC.parent_object_id
WHERE SKC.type_desc = N'UNIQUE_CONSTRAINT'
ORDER BY SCH.name, TBL.name

-- Primary Key constraints
SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''CONSTRAINT'', @level2name = [' + SKC.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.key_constraints SKC
 ON TBL.object_id = SKC.parent_object_id
WHERE SKC.type_desc = N'PRIMARY_KEY_CONSTRAINT'
ORDER BY SCH.name, TBL.name

-- Default Constraints
SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''CONSTRAINT'', @level2name = [' + SDC.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.default_constraints SDC
 ON TBL.object_id = SDC.parent_object_id
ORDER BY SCH.name, TBL.name

-- Check constraints

SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''CONSTRAINT'', @level2name = [' + CHK.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.check_constraints CHK
 ON TBL.object_id = CHK.parent_object_id
ORDER BY SCH.name, TBL.name

-- Foreign key constraints

SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''CONSTRAINT'', @level2name = [' + SFK.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.foreign_keys SFK
 ON TBL.object_id = SFK.parent_object_id
ORDER BY SCH.name, TBL.name

-- Table Indexes
SELECT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''INDEX'', @level2name = [' + SIX.name + '], @name = N''Description'', @value = N'''''
FROM sys.indexes SIX
 INNER JOIN sys.tables TBL
 INNER JOIN sys.schemas SCH
 ON TBL.schema_id = SCH.schema_id 
 ON SIX.object_id = TBL.object_id

WHERE SIX.is_primary_key = 0
 AND SIX.is_unique = 0

-- Table triggers

SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''TABLE'', @level1name =[' + TBL.name + '] ,@level2type = N''TRIGGER'', @level2name = [' + TRG.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.tables TBL
 ON SCH.schema_id = TBL.schema_id 
 INNER JOIN sys.triggers TRG
 ON TBL.object_id = TRG.parent_id
ORDER BY SCH.name, TBL.name

-- Views
SELECT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''VIEW'', @level1name =[' + VIW.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.views VIW 
 ON SCH.schema_id = VIW.schema_id

-- View Columns
SELECT TOP (100) PERCENT
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''VIEW'', @level1name =[' + VIW.name + '] ,@level2type = N''COLUMN'', @level2name = [' + COL.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.views VIW
 ON SCH.schema_id = VIW.schema_id 
 INNER JOIN sys.columns COL
 ON VIW.object_id = COL.object_id
ORDER BY SCH.name, VIW.name, COL.column_id

-- View indexes
SELECT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''VIEW'', @level1name =[' + VIW.name + '] ,@level2type = N''INDEX'', @level2name = [' + SIX.name + '], @name = N''Description'', @value = N'''''
FROM sys.indexes SIX
 INNER JOIN sys.views VIW
 INNER JOIN sys.schemas SCH
 ON VIW.schema_id = SCH.schema_id 
 ON SIX.object_id = VIW.object_id
 
-- View triggers
  
SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''VIEW'', @level1name =[' + VIW.name + '] ,@level2type = N''TRIGGER'', @level2name = [' + TRG.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas SCH
 INNER JOIN sys.views VIW
 ON SCH.schema_id = VIW.schema_id 
 INNER JOIN sys.triggers TRG
 ON VIW.object_id = TRG.parent_id
ORDER BY SCH.name, VIW.name

-- Stored Procedures
SELECT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''PROCEDURE'', @level1name =[' + PRC.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas AS SCH 
 INNER JOIN sys.procedures PRC
 ON SCH.schema_id = PRC.schema_id
 
-- Stored Procedure Parameters

SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''PROCEDURE'', @level1name =[' + PRC.name + '] ,@level2type = N''PARAMETER'', @level2name = [' + PRM.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas AS SCH
 INNER JOIN sys.procedures PRC
 ON SCH.schema_id = PRC.schema_id 
 INNER JOIN sys.parameters PRM
 ON PRC.object_id = PRM.object_id
ORDER BY PRM.parameter_id

-- Functions

SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''FUNCTION'', @level1name =[' + OBJ.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas AS SCH 
 INNER JOIN sys.objects OBJ
 ON SCH.schema_id = OBJ.schema_id
WHERE OBJ.is_ms_shipped = 0 
 AND OBJ.type_desc LIKE N'%FUNCTION%'

-- Function Parameters
SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@level1type = N''FUNCTION'', @level1name =[' + OBJ.name + '] ,@level2type = N''PARAMETER'', @level2name = [' + PRM.name + '], @name = N''Description'', @value = N'''''
FROM sys.schemas AS SCH 
 INNER JOIN sys.objects OBJ
 ON SCH.schema_id = OBJ.schema_id 
 INNER JOIN sys.parameters PRM
 ON OBJ.object_id = PRM.object_id
WHERE OBJ.is_ms_shipped = 0
 AND OBJ.type_desc LIKE N'%FUNCTION%'
 AND PRM.name IS NOT NULL
 AND LEN(PRM.name) > 0
 
-- DDL Triggers
SELECT TOP (100) PERCENT 
'EXEC sys.sp_addextendedproperty @level0type = N''TRIGGER'', @level0name = [' + TRG.name + '] ,@name = N''Description'', @value = N'''''
FROM sys.triggers TRG
WHERE TRG.parent_class_desc = N'DATABASE' 

-- Partition functions
SELECT
'EXEC sys.sp_addextendedproperty @level0type = N''PARTITION FUNCTION'', @level0name = [' + PFN.name + '] ,@name = N''Description'', @value = N'''''
FROM sys.partition_functions PFN

-- Partition Schemes
SELECT
'EXEC sys.sp_addextendedproperty @level0type = N''PARTITION SCHEME'', @level0name = [' + PSC.name + '] ,@name = N''Description'', @value = N'''''
FROM sys.partition_schemes PSC


-- ROLLBACK