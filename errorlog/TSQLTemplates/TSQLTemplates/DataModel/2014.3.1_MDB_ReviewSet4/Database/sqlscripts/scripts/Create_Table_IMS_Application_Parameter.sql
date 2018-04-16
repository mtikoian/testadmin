USE netikip 

go 

SET ansi_nulls ON; 
go 

SET quoted_identifier ON; 
go 

SET ansi_padding ON; 
go 

/* 
 File Name				: Create_Table_IMS_Application_Menu_Parameter.sql 
 Description			: This table to store application menu items and and it's properties data
 Created By             : vperala 
 Created Date			: 03/11/2014 
 Modification History   : 
 ------------------------------------------------------------------------------ 
 Date    Modified By     Description 
*/ 
PRINT ''; 

PRINT '----------------------------------------'; 

PRINT 'TABLE script for IMS_Application_Menu_Parameter'; 

PRINT '----------------------------------------'; 

BEGIN try 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application_Menu_Parameter') 
      BEGIN 
          DROP TABLE dbo.IMS_Application_Menu_Parameter; 

          PRINT 'Table dbo.IMS_Application_Menu_Parameter has been dropped.'; 
      END; 

    CREATE TABLE dbo.IMS_Application_Menu_Parameter
      ( 
		 IMS_Application_Parameter_Id int		identity(1,1) NOT NULL,
         Menu_Id					int				    NOT NULL,  --Primary Key, 
		 Parameter_Nm				varchar(100)		NOT NULL,
		 Parameter_Order_Num		int					NOT NULL,
		 Parameter_Val				varchar(100)		NULL,
		 Parameter_Type_Id			int					NOT NULL, --Int
         Create_User_Id				varchar(30)			NOT NULL, --Created user id
         Create_Dt					datetime			NOT NULL, --Created date and time               
         Update_User_Id				varchar(30)			NOT NULL, --updated userid
         Update_Dt					datetime			NOT NULL  --updated date and time
      ); 

    PRINT 'Adding constraints to TABLE dbo.IMS_Application_Menu_Parameter'; 


    ALTER TABLE dbo.IMS_Application_Menu_Parameter 
      ADD CONSTRAINT PK__IMS_Application_Menu_Parameter PRIMARY KEY CLUSTERED (IMS_Application_Parameter_Id),
      CONSTRAINT UQ__IMS_Application_Menu_Parameter__Menu_Id_Parameter_Nm UNIQUE NONCLUSTERED  (Menu_Id,Parameter_Nm),
	  CONSTRAINT UQ__IMS_Application_Menu_Parameter__Menu_Id_Parameter_Order_Num UNIQUE NONCLUSTERED  (Menu_Id,Parameter_Order_Num),
	  CONSTRAINT FK_IMS_Application_Menu_Parameter_Menu_Id FOREIGN KEY (Menu_Id) REFERENCES dbo.IMS_Application_Menu(Menu_Id),
	  CONSTRAINT FK_IMS_Application_Menu_Parameter_Type_Id FOREIGN KEY (Parameter_Type_Id) REFERENCES dbo.IMS_Application_Parameter_Type(Parameter_Type_Id),
	  CONSTRAINT DF__IMS_Application_Menu_Parameter__Create_User_Id default SYSTEM_USER for Create_User_Id,
	  CONSTRAINT DF__IMS_Application_Menu_Parameter__Create_Dt default GETDATE() for Create_Dt,    
      CONSTRAINT DF__IMS_Application_Menu_Parameter__Update_User_Id default SYSTEM_USER for Update_User_Id,
      CONSTRAINT DF__IMS_Application_Menu_Parameter__Update_Dt default GETDATE() for Update_Dt;



    -- Validate if the table has been created. 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application_Menu_Parameter') 
      BEGIN 
          PRINT 'Table dbo.IMS_Application_Menu_Parameter has been created.' 
      END; 
    ELSE 
      BEGIN 
          PRINT 'Failed to create Table dbo.IMS_Application_Menu_Parameter!!!!!!!' 
      END; 
END try 

BEGIN catch 
    DECLARE @error_Message VARCHAR(2100); 
    DECLARE @error_Severity INT; 
    DECLARE @error_State INT; 

    SET @error_Message = Error_message(); 
    SET @error_Severity = Error_severity() ;
    SET @error_State = Error_state(); 

    RAISERROR (@error_Message,@error_Severity,@error_State); 
END catch; 

PRINT ''; 

PRINT 'End of TABLE script for IMS_Application_Menu_Parameter'; 

PRINT '----------------------------------------'; 