-- ====================================================
-- Project: BIS Account Restriction Facility (BARF)
--
-- POBrien Tracker 936 Tag 20120917.1
--
--    Modified constraint Secured_User_AK to include 
--    Organization_ID.
-- ====================================================
-- altered for SECURED_USER_TYPE table, column --2012.11.16

-- ==================
-- Audit Trail tables
-- ==================
CREATE TABLE  $(BIS_SECURITY_SCHEMA).DB_CONTROL_HISTORY
(
   DB_Control_History_Dt    DATETIME NOT NULL DEFAULT (getdate ()),
   Structure_Version_Tag    VARCHAR (20) NULL,
   Code_Version_Tag         VARCHAR (20) NULL,
   Test_Env_Flg             BIT NOT NULL,
   Delta_Comment_Tx         VARCHAR (100) NULL,
   Last_Change_Process_Dt   DATETIME NULL,
   DB_Control_Ver_Num       SMALLINT NOT NULL
)
ON [PRIMARY];
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'DB_CONTROL_HISTORY')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).DB_CONTROL_HISTORY >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).DB_CONTROL_HISTORY >>>'
GO

CREATE TABLE $(BIS_SECURITY_SCHEMA).DB_CONTROL
(
   Structure_Version_Tag    VARCHAR (20) NULL,
   Code_Version_Tag         VARCHAR (20) NULL,
   Test_Env_Flg             BIT NOT NULL DEFAULT ( (0)),
   Last_Change_Process_Dt   DATETIME NULL,
   DB_Control_Ver_Num       SMALLINT NOT NULL DEFAULT ( (1))
)
ON [PRIMARY];
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'DB_CONTROL')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).DB_CONTROL >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).DB_CONTROL >>>'
GO

Insert Into $(BIS_SECURITY_SCHEMA).DB_CONTROL 
   (Structure_Version_Tag,Code_Version_Tag,Test_Env_Flg,Last_Change_Process_Dt,DB_Control_Ver_Num)
Values ('BARF 0.3', '1/25/2012',0,NULL,1);
GO

CREATE TABLE $(BIS_SECURITY_SCHEMA).AUDIT_TRAIL
(
   Audit_Trail_ID          NUMERIC (15, 0) IDENTITY (1, 1) NOT NULL,
   Structure_Version_Tag   VARCHAR (20) NULL,
   Table_Name              VARCHAR (32) NOT NULL,
   Column_Name             VARCHAR (32) NOT NULL,
   Audit_Type              VARCHAR (10) NOT NULL,
   [User_ID]               VARCHAR (80) NULL,
   Audit_Timestamp         DATETIME NOT NULL DEFAULT (getdate ()),
   Old_Value               VARCHAR (1000) NULL,
   New_Value               VARCHAR (1000) NULL,
   Primary_Key_Value       VARCHAR (200) NOT NULL,
   Sequence_Num            NUMERIC (15, 0) NOT NULL,
   Split_Num               INT NOT NULL DEFAULT(1),
   CONSTRAINT AUDIT_TRAIL_PK PRIMARY KEY
      CLUSTERED
      (Audit_Trail_ID ASC)
      WITH (PAD_INDEX = OFF,
            FILLFACTOR = 100,
            IGNORE_DUP_KEY = OFF,
            STATISTICS_NORECOMPUTE = OFF,
            ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON)
      ON [PRIMARY]
)
ON [PRIMARY];
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'AUDIT_TRAIL')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).AUDIT_TRAIL >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).AUDIT_TRAIL >>>'
GO

CREATE UNIQUE NONCLUSTERED INDEX AUDIT_TRAIL_IX01
   ON $(BIS_SECURITY_SCHEMA).AUDIT_TRAIL (Audit_Timestamp, Audit_Trail_ID)
   WITH (PAD_INDEX = OFF,
         FILLFACTOR = 100,
         IGNORE_DUP_KEY = OFF,
         STATISTICS_NORECOMPUTE = OFF,
         ALLOW_ROW_LOCKS = ON,
         ALLOW_PAGE_LOCKS = ON)
   ON [PRIMARY];
GO






CREATE TABLE $(BIS_SECURITY_SCHEMA).QUALIFICATION_COLUMN(
    Qualification_Column_ID      int             IDENTITY(1,1),
    Qualification_Column_Name    varchar(128)    NOT NULL,
    Qualification_Column_Display_Name VARCHAR(30) NULL,
    CONSTRAINT QUALIFICATION_COLUMN_PK PRIMARY KEY CLUSTERED (Qualification_Column_ID),
    CONSTRAINT QUALIFICATION_COLUMN_AK  UNIQUE (Qualification_Column_Name)
)
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'QUALIFICATION_COLUMN')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).QUALIFICATION_COLUMN >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).QUALIFICATION_COLUMN >>>'
GO


CREATE TABLE $(BIS_SECURITY_SCHEMA).ORGANIZATION(
    Organization_ID        int            IDENTITY(1,1),
    Organization_Name      varchar(40)    NOT NULL,
    SEI_Organization_ID    varchar(20)    NULL,
    Bank_Master_ID         smallint       NOT NULL,
    Supervisor_ID          smallint       NOT NULL,
    Shared_Master_Flag     bit            NOT NULL,
    Create_Dt              DATETIME NOT NULL,
    Create_User_ID         INT NOT NULL,
    Update_Dt              DATETIME NULL,
    Update_User_ID         INT NULL,
    Organization_Ver_Num   SMALLINT NOT NULL,
    CONSTRAINT ORGANIZATION_PK PRIMARY KEY CLUSTERED (Organization_ID)
)
go

ALTER TABLE $(BIS_SECURITY_SCHEMA).ORGANIZATION ADD 
    CONSTRAINT ORGANIZATION_AK UNIQUE NONCLUSTERED (Organization_Name);
go
ALTER TABLE $(BIS_SECURITY_SCHEMA).ORGANIZATION ADD 
    CONSTRAINT ORGANIZATION_AK2 UNIQUE NONCLUSTERED (SEI_Organization_ID);
go
ALTER TABLE $(BIS_SECURITY_SCHEMA).ORGANIZATION ADD 
    CONSTRAINT ORGANIZATION_AK3 UNIQUE NONCLUSTERED (Supervisor_ID);
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'ORGANIZATION')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).ORGANIZATION >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).ORGANIZATION >>>'
GO

-- 20120917.1 Added Organization_ID to Secured_User_AK.
--
CREATE TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER(
    Secured_User_ID          int             IDENTITY(1,1),
    Organization_ID          int             NOT NULL,
    Secured_User_Login_ID    varchar(100)    NOT NULL,
    Create_Dt                DATETIME NOT NULL,
    Create_User_ID           INT NOT NULL,
    Update_Dt                DATETIME NULL,
    Update_User_ID           INT NULL,
    Secured_User_Ver_Num     SMALLINT NOT NULL,
    Secured_User_Type_Cd       SMALLINT NOT NULL DEFAULT 2, --2012.11.16
    CONSTRAINT SECURED_USER_PK PRIMARY KEY CLUSTERED (Secured_User_ID),
    CONSTRAINT SECURED_USER_AK  UNIQUE (Secured_User_Login_ID, Organization_ID)
)
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'SECURED_USER')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER >>>'
GO
CREATE TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER_TYPE(
    Secured_User_Type_Cd     SMALLINT NOT NULL ,
    Secured_User_Type	     VARCHAR(20) NULL,
    CONSTRAINT SECURED_USER_TYPE_PK PRIMARY KEY CLUSTERED (SECURED_USER_TYPE_Cd)
)
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'SECURED_USER')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER >>>'
GO

CREATE TABLE $(BIS_SECURITY_SCHEMA).USER_RULE(
    User_Rule_ID               int            IDENTITY(1,1),
    Secured_User_ID            int            NOT NULL,
    Qualification_Column_ID    int            NOT NULL,
    Compare_Value_Text         varchar(20)    NULL,
    Compare_Value_Num          int            NULL,
    All_Access_Flag            bit            NULL,
    Create_Dt                  DATETIME NOT NULL,
    Create_User_ID             INT NOT NULL,
    Update_Dt                  DATETIME NULL,
    Update_User_ID             INT NULL,
    User_Rule_Ver_Num          SMALLINT NOT NULL,
    CONSTRAINT USER_RULE_PK PRIMARY KEY CLUSTERED (User_Rule_ID)
)
go

CREATE INDEX USER_RULE_IX1 ON $(BIS_SECURITY_SCHEMA).USER_RULE(Secured_User_ID, Qualification_Column_ID);
go


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' AND table_name = N'USER_RULE')
   PRINT '<<< CREATED TABLE $(BIS_SECURITY_SCHEMA).USER_RULE >>>'
ELSE
   PRINT '<<< FAILED CREATING TABLE $(BIS_SECURITY_SCHEMA).USER_RULE >>>'
GO


ALTER TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER ADD CONSTRAINT RefORGANIZATION27 
    FOREIGN KEY (Organization_ID)
    REFERENCES $(BIS_SECURITY_SCHEMA).ORGANIZATION(Organization_ID)
go

ALTER TABLE $(BIS_SECURITY_SCHEMA).USER_RULE ADD CONSTRAINT RefQUALIFICATION_COLUMN11 
    FOREIGN KEY (Qualification_Column_ID)
    REFERENCES $(BIS_SECURITY_SCHEMA).QUALIFICATION_COLUMN(Qualification_Column_ID);
go

ALTER TABLE $(BIS_SECURITY_SCHEMA).USER_RULE ADD CONSTRAINT RefSECURED_USER26 
    FOREIGN KEY (Secured_User_ID)
    REFERENCES $(BIS_SECURITY_SCHEMA).SECURED_USER(Secured_User_ID);
go


ALTER TABLE $(BIS_SECURITY_SCHEMA).SECURED_USER ADD CONSTRAINT RefSecuredUser 
    FOREIGN KEY (Secured_User_Type_Cd)
    REFERENCES $(BIS_SECURITY_SCHEMA).Secured_User_Type (Secured_User_Type_Cd)
go 
INSERT INTO
  $(BIS_SECURITY_SCHEMA).QUALIFICATION_COLUMN(Qualification_Column_Name, Qualification_Column_Display_Name)
VALUES
  ('Account_ID', 'Account'),
  ('Control_ID', 'Control Id'),
  ('Administrator_Cd', 'Administrator'),
  ('Branch_Cd', 'Branch'),
  ('Accountant_Cd', 'Accountant'),
  ('Senior_Administrator_Cd', 'Senior Administrator'),
  ('Minor_Account_Tp', 'Minor Account Type'),
  ('Investment_Officer_Cd', 'Investment Officer');
GO


INSERT BISSec.SECURED_USER_TYPE (Secured_User_Type_Cd, Secured_User_Type)
VALUES (1, 'Batch User'),
        (2, 'User')