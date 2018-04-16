-- SQL generated Wed Jan  4 12:42:10 2012 by BuildAuditTriggersW process

-- REQUIRED COLUMNS = (?^i:^CREATE_DT$|^CREATE_USER_ID$|^UPDATE_DT$|^UPDATE_USER_ID$)
-- EXCLUDE_TABLES   = (?^i:^AUDIT_TRAIL$|^DB_CONTROL$|^DB_CONTROL_HISTORY$)
-- EXCLUDE_COLUMNS  = (?^i:^CREATE_DT$|^CREATE_USER_ID$|^UPDATE_DT$|^UPDATE_USER_ID$)

-- CURRENT_DATABASE is BIS_11_4
-- CURRENT_SCHEMA   is BISSec

IF OBJECT_ID('BISSec.trg_IUD_ORGANIZATION_AUDIT') IS NOT NULL
   DROP TRIGGER BISSec.trg_IUD_ORGANIZATION_AUDIT
GO

CREATE TRIGGER BISSec.trg_IUD_ORGANIZATION_AUDIT
ON BISSec.ORGANIZATION
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan  4 12:42:10 2012 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Organization_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'ORGANIZATION';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From BISSec.DB_CONTROL;

   -- Get the current date and time to use on each audit trail row
   Set @l_Datetime = getdate();

   IF (SELECT Count(*) FROM inserted) > 0
   BEGIN
      IF (SELECT Count(*) FROM deleted) > 0
      BEGIN
         -- Update action
         -- Audit type and user id
         Set @l_AuditType = 'UPDATE';

         -- If the column has been changed, audit it
         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Name',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_Name,
                i.Organization_Name,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_Name <> d.Organization_Name THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'SEI_Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.SEI_Organization_ID,
                i.SEI_Organization_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.SEI_Organization_ID <> d.SEI_Organization_ID THEN 1
                  WHEN i.SEI_Organization_ID IS NULL AND d.SEI_Organization_ID IS NOT NULL THEN 1
                  WHEN i.SEI_Organization_ID IS NOT NULL AND d.SEI_Organization_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Bank_Master_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Bank_Master_ID,
                i.Bank_Master_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Bank_Master_ID <> d.Bank_Master_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Supervisor_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Supervisor_ID,
                i.Supervisor_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Supervisor_ID <> d.Supervisor_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Shared_Master_Flag',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Shared_Master_Flag,
                i.Shared_Master_Flag,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Shared_Master_Flag <> d.Shared_Master_Flag THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_Ver_Num,
                i.Organization_Ver_Num,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_Ver_Num <> d.Organization_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Name',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_Name,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'SEI_Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.SEI_Organization_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Bank_Master_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Bank_Master_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Supervisor_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Supervisor_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Shared_Master_Flag',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Shared_Master_Flag,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_Ver_Num,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_Name',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_Name,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'SEI_Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.SEI_Organization_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Bank_Master_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Bank_Master_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Supervisor_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Supervisor_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Shared_Master_Flag',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Shared_Master_Flag,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_Ver_Num,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'BISSec' and table_name = N'vw_ORGANIZATION_AUDIT')
   BEGIN
      DROP VIEW BISSec.vw_ORGANIZATION_AUDIT;
      PRINT 'VIEW BISSec.vw_ORGANIZATION_AUDIT has been dropped.';
   END;
GO

CREATE VIEW BISSec.vw_ORGANIZATION_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Organization_Name) AS OLD_Organization_Name,
       MAX(TAB.NEW_Organization_Name) AS NEW_Organization_Name,
       MAX(TAB.OLD_SEI_Organization_ID) AS OLD_SEI_Organization_ID,
       MAX(TAB.NEW_SEI_Organization_ID) AS NEW_SEI_Organization_ID,
       MAX(TAB.OLD_Bank_Master_ID) AS OLD_Bank_Master_ID,
       MAX(TAB.NEW_Bank_Master_ID) AS NEW_Bank_Master_ID,
       MAX(TAB.OLD_Supervisor_ID) AS OLD_Supervisor_ID,
       MAX(TAB.NEW_Supervisor_ID) AS NEW_Supervisor_ID,
       MAX(TAB.OLD_Shared_Master_Flag) AS OLD_Shared_Master_Flag,
       MAX(TAB.NEW_Shared_Master_Flag) AS NEW_Shared_Master_Flag,
       MAX(TAB.OLD_Organization_Ver_Num) AS OLD_Organization_Ver_Num,
       MAX(TAB.NEW_Organization_Ver_Num) AS NEW_Organization_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Name' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Name,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Name' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Name,
                    CASE AT.COLUMN_NAME
                       WHEN 'SEI_Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_SEI_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'SEI_Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_SEI_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Bank_Master_ID' THEN AT.OLD_VALUE
                    END AS OLD_Bank_Master_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Bank_Master_ID' THEN AT.NEW_VALUE
                    END AS NEW_Bank_Master_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Supervisor_ID' THEN AT.OLD_VALUE
                    END AS OLD_Supervisor_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Supervisor_ID' THEN AT.NEW_VALUE
                    END AS NEW_Supervisor_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Shared_Master_Flag' THEN AT.OLD_VALUE
                    END AS OLD_Shared_Master_Flag,
                    CASE AT.COLUMN_NAME
                       WHEN 'Shared_Master_Flag' THEN AT.NEW_VALUE
                    END AS NEW_Shared_Master_Flag,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Ver_Num
             FROM BISSec.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'ORGANIZATION') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('BISSec.trg_IUD_SECURED_USER_AUDIT') IS NOT NULL
   DROP TRIGGER BISSec.trg_IUD_SECURED_USER_AUDIT
GO

CREATE TRIGGER BISSec.trg_IUD_SECURED_USER_AUDIT
ON BISSec.SECURED_USER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan  4 12:42:10 2012 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Secured_User_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'SECURED_USER';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From BISSec.DB_CONTROL;

   -- Get the current date and time to use on each audit trail row
   Set @l_Datetime = getdate();

   IF (SELECT Count(*) FROM inserted) > 0
   BEGIN
      IF (SELECT Count(*) FROM deleted) > 0
      BEGIN
         -- Update action
         -- Audit type and user id
         Set @l_AuditType = 'UPDATE';

         -- If the column has been changed, audit it
         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Secured_User_ID,
                i.Secured_User_ID,
                'Secured_User_ID:'+ISNULL(CAST(i.Secured_User_ID as varchar),CAST(d.Secured_User_ID as varchar)),
                row_number() over (order by i.Secured_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Secured_User_ID = i.Secured_User_ID
         Where CASE
                  WHEN i.Secured_User_ID <> d.Secured_User_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Secured_User_ID:'+ISNULL(CAST(i.Secured_User_ID as varchar),CAST(d.Secured_User_ID as varchar)),
                row_number() over (order by i.Secured_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Secured_User_ID = i.Secured_User_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_Login_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Secured_User_Login_ID,
                i.Secured_User_Login_ID,
                'Secured_User_ID:'+ISNULL(CAST(i.Secured_User_ID as varchar),CAST(d.Secured_User_ID as varchar)),
                row_number() over (order by i.Secured_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Secured_User_ID = i.Secured_User_ID
         Where CASE
                  WHEN i.Secured_User_Login_ID <> d.Secured_User_Login_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Secured_User_Ver_Num,
                i.Secured_User_Ver_Num,
                'Secured_User_ID:'+ISNULL(CAST(i.Secured_User_ID as varchar),CAST(d.Secured_User_ID as varchar)),
                row_number() over (order by i.Secured_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Secured_User_ID = i.Secured_User_ID
         Where CASE
                  WHEN i.Secured_User_Ver_Num <> d.Secured_User_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Secured_User_ID,
                'Secured_User_ID:'+cast(i.Secured_User_ID as varchar),
                row_number() over (order by i.Secured_User_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Secured_User_ID:'+cast(i.Secured_User_ID as varchar),
                row_number() over (order by i.Secured_User_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_Login_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Secured_User_Login_ID,
                'Secured_User_ID:'+cast(i.Secured_User_ID as varchar),
                row_number() over (order by i.Secured_User_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Secured_User_Ver_Num,
                'Secured_User_ID:'+cast(i.Secured_User_ID as varchar),
                row_number() over (order by i.Secured_User_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Secured_User_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Secured_User_ID,
              NULL,
              'Secured_User_ID:'+cast(d.Secured_User_ID as varchar),
              row_number() over (order by d.Secured_User_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Secured_User_ID:'+cast(d.Secured_User_ID as varchar),
              row_number() over (order by d.Secured_User_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Secured_User_Login_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Secured_User_Login_ID,
              NULL,
              'Secured_User_ID:'+cast(d.Secured_User_ID as varchar),
              row_number() over (order by d.Secured_User_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Secured_User_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Secured_User_Ver_Num,
              NULL,
              'Secured_User_ID:'+cast(d.Secured_User_ID as varchar),
              row_number() over (order by d.Secured_User_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'BISSec' and table_name = N'vw_SECURED_USER_AUDIT')
   BEGIN
      DROP VIEW BISSec.vw_SECURED_USER_AUDIT;
      PRINT 'VIEW BISSec.vw_SECURED_USER_AUDIT has been dropped.';
   END;
GO

CREATE VIEW BISSec.vw_SECURED_USER_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Secured_User_ID) AS OLD_Secured_User_ID,
       MAX(TAB.NEW_Secured_User_ID) AS NEW_Secured_User_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Secured_User_Login_ID) AS OLD_Secured_User_Login_ID,
       MAX(TAB.NEW_Secured_User_Login_ID) AS NEW_Secured_User_Login_ID,
       MAX(TAB.OLD_Secured_User_Ver_Num) AS OLD_Secured_User_Ver_Num,
       MAX(TAB.NEW_Secured_User_Ver_Num) AS NEW_Secured_User_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_ID' THEN AT.OLD_VALUE
                    END AS OLD_Secured_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_ID' THEN AT.NEW_VALUE
                    END AS NEW_Secured_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_Login_ID' THEN AT.OLD_VALUE
                    END AS OLD_Secured_User_Login_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_Login_ID' THEN AT.NEW_VALUE
                    END AS NEW_Secured_User_Login_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Secured_User_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Secured_User_Ver_Num
             FROM BISSec.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'SECURED_USER') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('BISSec.trg_IUD_USER_RULE_AUDIT') IS NOT NULL
   DROP TRIGGER BISSec.trg_IUD_USER_RULE_AUDIT
GO

CREATE TRIGGER BISSec.trg_IUD_USER_RULE_AUDIT
ON BISSec.USER_RULE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan  4 12:42:10 2012 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @User_Rule_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'USER_RULE';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From BISSec.DB_CONTROL;

   -- Get the current date and time to use on each audit trail row
   Set @l_Datetime = getdate();

   IF (SELECT Count(*) FROM inserted) > 0
   BEGIN
      IF (SELECT Count(*) FROM deleted) > 0
      BEGIN
         -- Update action
         -- Audit type and user id
         Set @l_AuditType = 'UPDATE';

         -- If the column has been changed, audit it
         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Rule_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.User_Rule_ID,
                i.User_Rule_ID,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.User_Rule_ID <> d.User_Rule_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Secured_User_ID,
                i.Secured_User_ID,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.Secured_User_ID <> d.Secured_User_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Qualification_Column_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Qualification_Column_ID,
                i.Qualification_Column_ID,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.Qualification_Column_ID <> d.Qualification_Column_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Compare_Value_Text',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Compare_Value_Text,
                i.Compare_Value_Text,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.Compare_Value_Text <> d.Compare_Value_Text THEN 1
                  WHEN i.Compare_Value_Text IS NULL AND d.Compare_Value_Text IS NOT NULL THEN 1
                  WHEN i.Compare_Value_Text IS NOT NULL AND d.Compare_Value_Text IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Compare_Value_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Compare_Value_Num,
                i.Compare_Value_Num,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.Compare_Value_Num <> d.Compare_Value_Num THEN 1
                  WHEN i.Compare_Value_Num IS NULL AND d.Compare_Value_Num IS NOT NULL THEN 1
                  WHEN i.Compare_Value_Num IS NOT NULL AND d.Compare_Value_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'All_Access_Flag',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.All_Access_Flag,
                i.All_Access_Flag,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.All_Access_Flag <> d.All_Access_Flag THEN 1
                  WHEN i.All_Access_Flag IS NULL AND d.All_Access_Flag IS NOT NULL THEN 1
                  WHEN i.All_Access_Flag IS NOT NULL AND d.All_Access_Flag IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO BISSec.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Rule_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.User_Rule_Ver_Num,
                i.User_Rule_Ver_Num,
                'User_Rule_ID:'+ISNULL(CAST(i.User_Rule_ID as varchar),CAST(d.User_Rule_ID as varchar)),
                row_number() over (order by i.User_Rule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.User_Rule_ID = i.User_Rule_ID
         Where CASE
                  WHEN i.User_Rule_Ver_Num <> d.User_Rule_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Rule_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.User_Rule_ID,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secured_User_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Secured_User_ID,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Qualification_Column_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Qualification_Column_ID,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Compare_Value_Text',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Compare_Value_Text,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Compare_Value_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Compare_Value_Num,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'All_Access_Flag',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.All_Access_Flag,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

         Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Rule_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.User_Rule_Ver_Num,
                'User_Rule_ID:'+cast(i.User_Rule_ID as varchar),
                row_number() over (order by i.User_Rule_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'User_Rule_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.User_Rule_ID,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Secured_User_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Secured_User_ID,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Qualification_Column_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Qualification_Column_ID,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Compare_Value_Text',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Compare_Value_Text,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Compare_Value_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Compare_Value_Num,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'All_Access_Flag',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.All_Access_Flag,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

       Insert Into BISSec.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'User_Rule_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.User_Rule_Ver_Num,
              NULL,
              'User_Rule_ID:'+cast(d.User_Rule_ID as varchar),
              row_number() over (order by d.User_Rule_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'BISSec' and table_name = N'vw_USER_RULE_AUDIT')
   BEGIN
      DROP VIEW BISSec.vw_USER_RULE_AUDIT;
      PRINT 'VIEW BISSec.vw_USER_RULE_AUDIT has been dropped.';
   END;
GO

CREATE VIEW BISSec.vw_USER_RULE_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_User_Rule_ID) AS OLD_User_Rule_ID,
       MAX(TAB.NEW_User_Rule_ID) AS NEW_User_Rule_ID,
       MAX(TAB.OLD_Secured_User_ID) AS OLD_Secured_User_ID,
       MAX(TAB.NEW_Secured_User_ID) AS NEW_Secured_User_ID,
       MAX(TAB.OLD_Qualification_Column_ID) AS OLD_Qualification_Column_ID,
       MAX(TAB.NEW_Qualification_Column_ID) AS NEW_Qualification_Column_ID,
       MAX(TAB.OLD_Compare_Value_Text) AS OLD_Compare_Value_Text,
       MAX(TAB.NEW_Compare_Value_Text) AS NEW_Compare_Value_Text,
       MAX(TAB.OLD_Compare_Value_Num) AS OLD_Compare_Value_Num,
       MAX(TAB.NEW_Compare_Value_Num) AS NEW_Compare_Value_Num,
       MAX(TAB.OLD_All_Access_Flag) AS OLD_All_Access_Flag,
       MAX(TAB.NEW_All_Access_Flag) AS NEW_All_Access_Flag,
       MAX(TAB.OLD_User_Rule_Ver_Num) AS OLD_User_Rule_Ver_Num,
       MAX(TAB.NEW_User_Rule_Ver_Num) AS NEW_User_Rule_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Rule_ID' THEN AT.OLD_VALUE
                    END AS OLD_User_Rule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Rule_ID' THEN AT.NEW_VALUE
                    END AS NEW_User_Rule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_ID' THEN AT.OLD_VALUE
                    END AS OLD_Secured_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secured_User_ID' THEN AT.NEW_VALUE
                    END AS NEW_Secured_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Qualification_Column_ID' THEN AT.OLD_VALUE
                    END AS OLD_Qualification_Column_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Qualification_Column_ID' THEN AT.NEW_VALUE
                    END AS NEW_Qualification_Column_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Compare_Value_Text' THEN AT.OLD_VALUE
                    END AS OLD_Compare_Value_Text,
                    CASE AT.COLUMN_NAME
                       WHEN 'Compare_Value_Text' THEN AT.NEW_VALUE
                    END AS NEW_Compare_Value_Text,
                    CASE AT.COLUMN_NAME
                       WHEN 'Compare_Value_Num' THEN AT.OLD_VALUE
                    END AS OLD_Compare_Value_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Compare_Value_Num' THEN AT.NEW_VALUE
                    END AS NEW_Compare_Value_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'All_Access_Flag' THEN AT.OLD_VALUE
                    END AS OLD_All_Access_Flag,
                    CASE AT.COLUMN_NAME
                       WHEN 'All_Access_Flag' THEN AT.NEW_VALUE
                    END AS NEW_All_Access_Flag,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Rule_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_User_Rule_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Rule_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_User_Rule_Ver_Num
             FROM BISSec.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'USER_RULE') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

