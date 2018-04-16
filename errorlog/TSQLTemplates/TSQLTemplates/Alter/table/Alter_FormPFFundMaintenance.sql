USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*      
==================================================================================================      
Name    : Alter_FormPFFundMaintenance     
Author  : PKJHA   - 10/23/2013      
Description : This has been created for executing Alter Scripts for FormPFFundMaintenance tables.   
             
==================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			 Date		   Description      
---------------------------------------------------------------------------------------------------      
PKJHA          10/23/2013      Droped four Column      
===================================================================================================      
*/    


BEGIN
DECLARE @defname VARCHAR(100) 
DECLARE @cmd     VARCHAR(1000)

IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FormPFFundMaintenance'  AND  COLUMN_NAME = 'IsFormPF')
	BEGIN
      
				SET @defname = 
		              (SELECT name 
		                 FROM sysobjects so JOIN sysconstraints sc
	 					   ON so.id = sc.constid 
						WHERE object_name(so.parent_obj) = 'FormPFFundMaintenance' 
		         AND so.xtype = 'D'
		         AND sc.colid = 
		              (SELECT colid FROM syscolumns 
		                WHERE id = object_id('dbo.FormPFFundMaintenance') AND 
		                 name = 'IsFormPF'))
		                  SET @cmd = 'ALTER TABLE dbo.FormPFFundMaintenance DROP CONSTRAINT '
		                       + @defname
		                   EXECUTE(@cmd)

      ALTER TABLE dbo.FormPFFundMaintenance DROP COLUMN IsFormPF 
      PRINT 'Column IsFormPF Droped'
	END
ELSE
	PRINT 'Column IsFormPF Not Droped'



IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FormPFFundMaintenance'  AND  COLUMN_NAME = 'IsCPOPQR')
	BEGIN
              
           SET @defname = 
		              (SELECT name 
		                 FROM sysobjects so JOIN sysconstraints sc
	 					   ON so.id = sc.constid 
						WHERE object_name(so.parent_obj) = 'FormPFFundMaintenance' 
		         AND so.xtype = 'D'
		         AND sc.colid = 
		              (SELECT colid FROM syscolumns 
		                WHERE id = object_id('dbo.FormPFFundMaintenance') AND 
		                 name = 'IsCPOPQR'))
		                  SET @cmd = 'ALTER TABLE dbo.FormPFFundMaintenance DROP CONSTRAINT '
		                       + @defname
		                   EXECUTE(@cmd) 
         
      ALTER TABLE dbo.FormPFFundMaintenance DROP COLUMN IsCPOPQR 
	  PRINT 'Column IsCPOPQR Droped'
	END
ELSE
	PRINT 'Column IsCPOPQR Not Droped'


IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FormPFFundMaintenance'  AND  COLUMN_NAME = 'IsAIFMD')
	BEGIN

                   
           SET @defname = 
		              (SELECT name 
		                 FROM sysobjects so JOIN sysconstraints sc
	 					   ON so.id = sc.constid 
						WHERE object_name(so.parent_obj) = 'FormPFFundMaintenance' 
		         AND so.xtype = 'D'
		         AND sc.colid = 
		              (SELECT colid FROM syscolumns 
		                WHERE id = object_id('dbo.FormPFFundMaintenance') AND 
		                 name = 'IsAIFMD'))
		                  SET @cmd = 'ALTER TABLE dbo.FormPFFundMaintenance DROP CONSTRAINT '
		                       + @defname
		                   EXECUTE(@cmd) 
  
      ALTER TABLE dbo.FormPFFundMaintenance DROP COLUMN IsAIFMD 
	  PRINT 'Column IsAIFMD Droped'
	END
ELSE
	PRINT 'Column IsAIFMD NotDroped'



IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FormPFFundMaintenance'  AND  COLUMN_NAME = 'IsOpera')
	BEGIN
                  

           SET @defname = 
		              (SELECT name 
		                 FROM sysobjects so JOIN sysconstraints sc
	 					   ON so.id = sc.constid 
						WHERE object_name(so.parent_obj) = 'FormPFFundMaintenance' 
		         AND so.xtype = 'D'
		         AND sc.colid = 
		              (SELECT colid FROM syscolumns 
		                WHERE id = object_id('dbo.FormPFFundMaintenance') AND 
		                 name = 'IsOpera'))
		                  SET @cmd = 'ALTER TABLE dbo.FormPFFundMaintenance DROP CONSTRAINT '
		                       + @defname
		                   EXECUTE(@cmd) 
 
      ALTER TABLE dbo.FormPFFundMaintenance DROP COLUMN IsOpera 
	  PRINT 'Column IsOpera Droped'
	END
ELSE
	PRINT 'Column IsOpera Not Droped'

END
GO







