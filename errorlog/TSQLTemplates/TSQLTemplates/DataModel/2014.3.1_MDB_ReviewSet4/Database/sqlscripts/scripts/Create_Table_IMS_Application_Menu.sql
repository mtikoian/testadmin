USE netikip 

go 

SET ansi_nulls ON; 
go 

SET quoted_identifier ON; 
go 

SET ansi_padding ON; 
go 

/* 
 File Name				: Create_Table_IMS_Application_Menu.sql 
 Description			: This table to store application menu items and and it's properties data
 Created By             : vperala 
 Created Date			: 03/11/2014 
 Modification History   : 
 ------------------------------------------------------------------------------ 
 Date    Modified By     Description 
*/ 
PRINT ''; 

PRINT '----------------------------------------'; 

PRINT 'TABLE script for IMS_Application_Menu'; 

PRINT '----------------------------------------'; 

BEGIN try 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application_Menu') 
      BEGIN 
          DROP TABLE dbo.IMS_Application_Menu; 

          PRINT 'Table dbo.IMS_Application_Menu has been dropped.'; 
      END; 

    CREATE TABLE dbo.IMS_Application_Menu
      ( 
         Menu_Id					int				    NOT NULL,  --Primary Key, 
		 Application_Id				int					NOT NULL,  --Application Id, Fk to IMS_Application table. 			
		 Menu_Nm					varchar(100)		NOT NULL,  --Menu Name to be displayed
		 Parent_Menu_Id				int					NOT NULL,  --Parent Menu Id
		 Open_In_New_Window_Fl		bit					NOT NULL,  --Flag to open in a new window
		 Display_Seq_Num			int					NOT NULL,  --Menu order seqeunce
		 Display_Role_Id			varchar(20)			NULL,	   --Each application has pre-defined Id for display on screen. There is no action assoicated with it.
		 Action_Nm					varchar(50)			NULL,	   --MVC Action Name	
		 Controller_Nm				varchar(50)			NULL,      --MVC controller Name
		 Tooltip_Tx					varchar(100)		NULL,	   --Menu tool tip
		 URL_Tx						varchar(255)		NULL,	   --Menu Url
         Create_User_Id				varchar(30)			NOT NULL, --Created user id
         Create_Dt					datetime			NOT NULL, --Created date and time               
         Update_User_Id				varchar(30)			NOT NULL, --updated userid
         Update_Dt					datetime			NOT NULL  --updated date and time
      ); 

    PRINT 'Adding constraints to TABLE dbo.IMS_Application_Menu'; 


    ALTER TABLE dbo.IMS_Application_Menu 
      ADD CONSTRAINT PK__IMS_Application_Menu_Menu_Id PRIMARY KEY CLUSTERED (Menu_Id),
      CONSTRAINT UQ__IMS_Application_Menu__Menu_Id_Application_Id UNIQUE NONCLUSTERED  (Application_Id,Menu_Nm),
	  CONSTRAINT FK_IMS_Application_Menu_IMS_Application_Application_Id FOREIGN KEY (Application_Id) REFERENCES dbo.IMS_Application(Application_Id),
	  CONSTRAINT DF_IMS_Application_Menu_Open_In_New_Window_Fl DEFAULT 0 FOR Open_In_New_Window_Fl,
	  CONSTRAINT DF__IMS_Application_Menu__Create_User_Id default SYSTEM_USER for Create_User_Id,
	  CONSTRAINT DF__IMS_Application_Menu__Create_Dt default GETDATE() for Create_Dt,    
      CONSTRAINT DF__IMS_Application_Menu__Update_User_Id default SYSTEM_USER for Update_User_Id,
      CONSTRAINT DF__IMS_Application_Menu__Update_Dt default GETDATE() for Update_Dt;



    -- Validate if the table has been created. 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application_Menu') 
      BEGIN 
          PRINT 'Table dbo.IMS_Application_Menu has been created.' 
      END; 
    ELSE 
      BEGIN 
          PRINT 'Failed to create Table dbo.IMS_Application_Menu!!!!!!!' 
      END; 
END try 

BEGIN catch 
    DECLARE @error_Message VARCHAR(2100); 
    DECLARE @error_Severity INT; 
    DECLARE @error_State INT; 

    SET @error_Message = Error_message(); 
    SET @error_Severity = Error_severity(); 
    SET @error_State = Error_state(); 

    RAISERROR (@error_Message,@error_Severity,@error_State); 
END catch; 

PRINT ''; 

PRINT 'End of TABLE script for IMS_Application_Menu'; 

PRINT '----------------------------------------'; 