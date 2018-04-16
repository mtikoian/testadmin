USE netikip 

go 

SET ansi_nulls ON; 
go 

SET quoted_identifier ON; 
go 

SET ansi_padding ON; 
go 

/* 
 File Name			 : Create_Table_IMS_Application.sql 
 Description         : This table to store application and it's properties data
 Created By          : vperala 
 Created Date        : 03/11/2014 
 Modification History  : 
 ------------------------------------------------------------------------------ 
 Date    Modified By     Description 
*/ 
PRINT ''; 

PRINT '----------------------------------------'; 

PRINT 'TABLE script for IMS_Application'; 

PRINT '----------------------------------------'; 

BEGIN try 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application') 
      BEGIN 
          DROP TABLE dbo.IMS_Application; 

          PRINT 'Table dbo.IMS_Application has been dropped.' 
      END; 

    CREATE TABLE dbo.IMS_Application
      ( 
         Application_Id					int NOT NULL,		  --Primary Key
		 Application_Nm					varchar(50) NOT NULL, --Application Name
		 Open_In_New_Window_Fl			bit NOT NULL,		  --Open in new window
		 Display_Seq_Num				int not NULL,		  --Dispaly sequence number; This helps to dropdown to populate menu
		 Top_Nav_Background_Color_Code	char(7) NULL,		  --Background color for Top_Nav
		 Top_Nav_Hilite_Color_Code		char(7) NULL,		  --Hilite color for Top_Nav
		 Tooltip_Tx						varchar(100)	NULL,	  --Tool tip forapplication
		 Application_URL_Tx				varchar(255)	NULL,	  --Application URL
		 Logo_Path_Tx					varchar(255)	NULL,	  --Logo Path
		 Logo_Tooltip_Tx				varchar(100)	NULL,	  --Logo tool tool tip
		 Display_Role_Id				varchar(20)		NULL,	  --Each application has pre-defined Id for display on screen. There is no action assoicated with it.
         Create_User_Id					varchar(30)     NOT NULL, --Created user id
         Create_Dt						datetime        NOT NULL, --Created date and time               
         Update_User_Id					varchar(30)     NOT NULL, --updated userid
         Update_Dt						datetime        NOT NULL  --updated date and time

      ); 

    PRINT 'Adding constraints to TABLE dbo.IMS_Application';


    ALTER TABLE dbo.IMS_Application 
      ADD CONSTRAINT PK__IMS_Application_Application_Id PRIMARY KEY CLUSTERED (Application_Id),
      CONSTRAINT UQ__IMS_Application__Application_Nm UNIQUE NONCLUSTERED  (Application_Nm),
	  CONSTRAINT DF__IMS_Application_Open_In_New_Window_Fl DEFAULT 0 FOR Open_In_New_Window_Fl,
	  CONSTRAINT DF__IMS_Application__Create_User_Id default SYSTEM_USER for Create_User_Id,
	  CONSTRAINT DF__IMS_Application__Create_Dt default GETDATE() for Create_Dt,    
      CONSTRAINT DF__IMS_Application__Update_User_Id default SYSTEM_USER for Update_User_Id,
      CONSTRAINT DF__IMS_Application__Update_Dt default GETDATE() for Update_Dt;



    -- Validate if the table has been created. 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application') 
      BEGIN 
          PRINT 'Table dbo.IMS_Application has been created.' 
      END; 
    ELSE 
      BEGIN 
          PRINT 'Failed to create Table dbo.IMS_Application!!!!!!!' 
      END; 
END try

BEGIN catch 
    DECLARE @error_Message VARCHAR(2100); 
    DECLARE @error_Severity INT; 
    DECLARE @error_State INT; 

    SET @error_Message = Error_message() ;
    SET @error_Severity = Error_severity() ;
    SET @error_State = Error_state() ;

    RAISERROR (@error_Message,@error_Severity,@error_State); 
END catch; 

PRINT ''; 

PRINT 'End of TABLE script for IMS_Application'; 

PRINT '----------------------------------------'; 