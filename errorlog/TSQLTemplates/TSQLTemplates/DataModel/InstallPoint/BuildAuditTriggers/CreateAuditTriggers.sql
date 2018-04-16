-- SQL generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

-- REQUIRED COLUMNS = (?^i:^CREATE_DT$|^CREATE_USER_ID$|^UPDATE_DT$|^UPDATE_USER_ID$)
-- EXCLUDE_TABLES   = (?^i:^AUDIT_TRAIL$|^DB_CONTROL$|^DB_CONTROL_HISTORY$)
-- EXCLUDE_COLUMNS  = (?^i:^CREATE_DT$|^CREATE_USER_ID$|^UPDATE_DT$|^UPDATE_USER_ID$)

-- CURRENT_DATABASE is InstallPoint
-- CURRENT_SCHEMA   is dbo

IF OBJECT_ID('dbo.trg_IUD_ADDRESS_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_ADDRESS_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_ADDRESS_AUDIT
ON dbo.ADDRESS
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Server_Address_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'ADDRESS';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Address_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Address_ID,
                i.Server_Address_ID,
                'Server_Address_ID:'+ISNULL(CAST(i.Server_Address_ID as varchar),CAST(d.Server_Address_ID as varchar)),
                row_number() over (order by i.Server_Address_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_Address_ID = i.Server_Address_ID
         Where CASE
                  WHEN i.Server_Address_ID <> d.Server_Address_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Address_Type_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Address_Type_ID,
                i.Address_Type_ID,
                'Server_Address_ID:'+ISNULL(CAST(i.Server_Address_ID as varchar),CAST(d.Server_Address_ID as varchar)),
                row_number() over (order by i.Server_Address_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_Address_ID = i.Server_Address_ID
         Where CASE
                  WHEN i.Address_Type_ID <> d.Address_Type_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Server_Address_ID:'+ISNULL(CAST(i.Server_Address_ID as varchar),CAST(d.Server_Address_ID as varchar)),
                row_number() over (order by i.Server_Address_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_Address_ID = i.Server_Address_ID
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_IP_Address_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_IP_Address_Tx,
                i.Server_IP_Address_Tx,
                'Server_Address_ID:'+ISNULL(CAST(i.Server_Address_ID as varchar),CAST(d.Server_Address_ID as varchar)),
                row_number() over (order by i.Server_Address_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_Address_ID = i.Server_Address_ID
         Where CASE
                  WHEN i.Server_IP_Address_Tx <> d.Server_IP_Address_Tx THEN 1
                  WHEN i.Server_IP_Address_Tx IS NULL AND d.Server_IP_Address_Tx IS NOT NULL THEN 1
                  WHEN i.Server_IP_Address_Tx IS NOT NULL AND d.Server_IP_Address_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Address_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Address_Nm,
                i.Server_Address_Nm,
                'Server_Address_ID:'+ISNULL(CAST(i.Server_Address_ID as varchar),CAST(d.Server_Address_ID as varchar)),
                row_number() over (order by i.Server_Address_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_Address_ID = i.Server_Address_ID
         Where CASE
                  WHEN i.Server_Address_Nm <> d.Server_Address_Nm THEN 1
                  WHEN i.Server_Address_Nm IS NULL AND d.Server_Address_Nm IS NOT NULL THEN 1
                  WHEN i.Server_Address_Nm IS NOT NULL AND d.Server_Address_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Address_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Address_Ver_Num,
                i.Address_Ver_Num,
                'Server_Address_ID:'+ISNULL(CAST(i.Server_Address_ID as varchar),CAST(d.Server_Address_ID as varchar)),
                row_number() over (order by i.Server_Address_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_Address_ID = i.Server_Address_ID
         Where CASE
                  WHEN i.Address_Ver_Num <> d.Address_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Address_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Address_ID,
                'Server_Address_ID:'+cast(i.Server_Address_ID as varchar),
                row_number() over (order by i.Server_Address_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Address_Type_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Address_Type_ID,
                'Server_Address_ID:'+cast(i.Server_Address_ID as varchar),
                row_number() over (order by i.Server_Address_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Server_Address_ID:'+cast(i.Server_Address_ID as varchar),
                row_number() over (order by i.Server_Address_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_IP_Address_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_IP_Address_Tx,
                'Server_Address_ID:'+cast(i.Server_Address_ID as varchar),
                row_number() over (order by i.Server_Address_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Address_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Address_Nm,
                'Server_Address_ID:'+cast(i.Server_Address_ID as varchar),
                row_number() over (order by i.Server_Address_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Address_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Address_Ver_Num,
                'Server_Address_ID:'+cast(i.Server_Address_ID as varchar),
                row_number() over (order by i.Server_Address_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Address_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Address_ID,
              NULL,
              'Server_Address_ID:'+cast(d.Server_Address_ID as varchar),
              row_number() over (order by d.Server_Address_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Address_Type_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Address_Type_ID,
              NULL,
              'Server_Address_ID:'+cast(d.Server_Address_ID as varchar),
              row_number() over (order by d.Server_Address_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Server_Address_ID:'+cast(d.Server_Address_ID as varchar),
              row_number() over (order by d.Server_Address_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_IP_Address_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_IP_Address_Tx,
              NULL,
              'Server_Address_ID:'+cast(d.Server_Address_ID as varchar),
              row_number() over (order by d.Server_Address_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Address_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Address_Nm,
              NULL,
              'Server_Address_ID:'+cast(d.Server_Address_ID as varchar),
              row_number() over (order by d.Server_Address_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Address_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Address_Ver_Num,
              NULL,
              'Server_Address_ID:'+cast(d.Server_Address_ID as varchar),
              row_number() over (order by d.Server_Address_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_ADDRESS_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_ADDRESS_AUDIT;
      PRINT 'VIEW dbo.vw_ADDRESS_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_ADDRESS_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Server_Address_ID) AS OLD_Server_Address_ID,
       MAX(TAB.NEW_Server_Address_ID) AS NEW_Server_Address_ID,
       MAX(TAB.OLD_Address_Type_ID) AS OLD_Address_Type_ID,
       MAX(TAB.NEW_Address_Type_ID) AS NEW_Address_Type_ID,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Server_IP_Address_Tx) AS OLD_Server_IP_Address_Tx,
       MAX(TAB.NEW_Server_IP_Address_Tx) AS NEW_Server_IP_Address_Tx,
       MAX(TAB.OLD_Server_Address_Nm) AS OLD_Server_Address_Nm,
       MAX(TAB.NEW_Server_Address_Nm) AS NEW_Server_Address_Nm,
       MAX(TAB.OLD_Address_Ver_Num) AS OLD_Address_Ver_Num,
       MAX(TAB.NEW_Address_Ver_Num) AS NEW_Address_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Address_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_Address_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Address_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_Address_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Address_Type_ID' THEN AT.OLD_VALUE
                    END AS OLD_Address_Type_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Address_Type_ID' THEN AT.NEW_VALUE
                    END AS NEW_Address_Type_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_IP_Address_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Server_IP_Address_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_IP_Address_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Server_IP_Address_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Address_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Server_Address_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Address_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Server_Address_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Address_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Address_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Address_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Address_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'ADDRESS') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_ALLOWABLE_PARAMETER_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_ALLOWABLE_PARAMETER_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_ALLOWABLE_PARAMETER_AUDIT
ON dbo.ALLOWABLE_PARAMETER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Parameter_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'ALLOWABLE_PARAMETER';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_ID,
                i.Parameter_ID,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parameter_ID <> d.Parameter_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Nm,
                i.Parameter_Nm,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parameter_Nm <> d.Parameter_Nm THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Dsc,
                i.Parameter_Dsc,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parameter_Dsc <> d.Parameter_Dsc THEN 1
                  WHEN i.Parameter_Dsc IS NULL AND d.Parameter_Dsc IS NOT NULL THEN 1
                  WHEN i.Parameter_Dsc IS NOT NULL AND d.Parameter_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Tag_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Tag_Tx,
                i.Parameter_Tag_Tx,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parameter_Tag_Tx <> d.Parameter_Tag_Tx THEN 1
                  WHEN i.Parameter_Tag_Tx IS NULL AND d.Parameter_Tag_Tx IS NOT NULL THEN 1
                  WHEN i.Parameter_Tag_Tx IS NOT NULL AND d.Parameter_Tag_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Keyword_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Keyword_Tx,
                i.Parameter_Keyword_Tx,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parameter_Keyword_Tx <> d.Parameter_Keyword_Tx THEN 1
                  WHEN i.Parameter_Keyword_Tx IS NULL AND d.Parameter_Keyword_Tx IS NOT NULL THEN 1
                  WHEN i.Parameter_Keyword_Tx IS NOT NULL AND d.Parameter_Keyword_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Data_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Data_Type_Cd,
                i.Data_Type_Cd,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Data_Type_Cd <> d.Data_Type_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Value_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Default_Value_Tx,
                i.Default_Value_Tx,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Default_Value_Tx <> d.Default_Value_Tx THEN 1
                  WHEN i.Default_Value_Tx IS NULL AND d.Default_Value_Tx IS NOT NULL THEN 1
                  WHEN i.Default_Value_Tx IS NOT NULL AND d.Default_Value_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Value_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Default_Value_Num,
                i.Default_Value_Num,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Default_Value_Num <> d.Default_Value_Num THEN 1
                  WHEN i.Default_Value_Num IS NULL AND d.Default_Value_Num IS NOT NULL THEN 1
                  WHEN i.Default_Value_Num IS NOT NULL AND d.Default_Value_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Value_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Default_Value_Fl,
                i.Default_Value_Fl,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Default_Value_Fl <> d.Default_Value_Fl THEN 1
                  WHEN i.Default_Value_Fl IS NULL AND d.Default_Value_Fl IS NOT NULL THEN 1
                  WHEN i.Default_Value_Fl IS NOT NULL AND d.Default_Value_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Reserved_Word_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Reserved_Word_Fl,
                i.Reserved_Word_Fl,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Reserved_Word_Fl <> d.Reserved_Word_Fl THEN 1
                  WHEN i.Reserved_Word_Fl IS NULL AND d.Reserved_Word_Fl IS NOT NULL THEN 1
                  WHEN i.Reserved_Word_Fl IS NOT NULL AND d.Reserved_Word_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parm_Domain_ID,
                i.Parm_Domain_ID,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parm_Domain_ID <> d.Parm_Domain_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Generate_Name_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Generate_Name_Fl,
                i.Generate_Name_Fl,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Generate_Name_Fl <> d.Generate_Name_Fl THEN 1
                  WHEN i.Generate_Name_Fl IS NULL AND d.Generate_Name_Fl IS NOT NULL THEN 1
                  WHEN i.Generate_Name_Fl IS NOT NULL AND d.Generate_Name_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Allowable_Parameter_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Allowable_Parameter_Ver_Num,
                i.Allowable_Parameter_Ver_Num,
                'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Allowable_Parameter_Ver_Num <> d.Allowable_Parameter_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_ID,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Nm,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Dsc,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Tag_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Tag_Tx,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Keyword_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Keyword_Tx,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Data_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Data_Type_Cd,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Value_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Default_Value_Tx,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Value_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Default_Value_Num,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Value_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Default_Value_Fl,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Reserved_Word_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Reserved_Word_Fl,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parm_Domain_ID,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Generate_Name_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Generate_Name_Fl,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Allowable_Parameter_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Allowable_Parameter_Ver_Num,
                'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Parameter_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_ID,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Nm,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Dsc,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Tag_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Tag_Tx,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Keyword_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Keyword_Tx,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Data_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Data_Type_Cd,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Default_Value_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Default_Value_Tx,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Default_Value_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Default_Value_Num,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Default_Value_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Default_Value_Fl,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Reserved_Word_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Reserved_Word_Fl,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parm_Domain_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parm_Domain_ID,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Generate_Name_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Generate_Name_Fl,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Allowable_Parameter_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Allowable_Parameter_Ver_Num,
              NULL,
              'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Parameter_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_ALLOWABLE_PARAMETER_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_ALLOWABLE_PARAMETER_AUDIT;
      PRINT 'VIEW dbo.vw_ALLOWABLE_PARAMETER_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_ALLOWABLE_PARAMETER_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Parameter_ID) AS OLD_Parameter_ID,
       MAX(TAB.NEW_Parameter_ID) AS NEW_Parameter_ID,
       MAX(TAB.OLD_Parameter_Nm) AS OLD_Parameter_Nm,
       MAX(TAB.NEW_Parameter_Nm) AS NEW_Parameter_Nm,
       MAX(TAB.OLD_Parameter_Dsc) AS OLD_Parameter_Dsc,
       MAX(TAB.NEW_Parameter_Dsc) AS NEW_Parameter_Dsc,
       MAX(TAB.OLD_Parameter_Tag_Tx) AS OLD_Parameter_Tag_Tx,
       MAX(TAB.NEW_Parameter_Tag_Tx) AS NEW_Parameter_Tag_Tx,
       MAX(TAB.OLD_Parameter_Keyword_Tx) AS OLD_Parameter_Keyword_Tx,
       MAX(TAB.NEW_Parameter_Keyword_Tx) AS NEW_Parameter_Keyword_Tx,
       MAX(TAB.OLD_Data_Type_Cd) AS OLD_Data_Type_Cd,
       MAX(TAB.NEW_Data_Type_Cd) AS NEW_Data_Type_Cd,
       MAX(TAB.OLD_Default_Value_Tx) AS OLD_Default_Value_Tx,
       MAX(TAB.NEW_Default_Value_Tx) AS NEW_Default_Value_Tx,
       MAX(TAB.OLD_Default_Value_Num) AS OLD_Default_Value_Num,
       MAX(TAB.NEW_Default_Value_Num) AS NEW_Default_Value_Num,
       MAX(TAB.OLD_Default_Value_Fl) AS OLD_Default_Value_Fl,
       MAX(TAB.NEW_Default_Value_Fl) AS NEW_Default_Value_Fl,
       MAX(TAB.OLD_Reserved_Word_Fl) AS OLD_Reserved_Word_Fl,
       MAX(TAB.NEW_Reserved_Word_Fl) AS NEW_Reserved_Word_Fl,
       MAX(TAB.OLD_Parm_Domain_ID) AS OLD_Parm_Domain_ID,
       MAX(TAB.NEW_Parm_Domain_ID) AS NEW_Parm_Domain_ID,
       MAX(TAB.OLD_Generate_Name_Fl) AS OLD_Generate_Name_Fl,
       MAX(TAB.NEW_Generate_Name_Fl) AS NEW_Generate_Name_Fl,
       MAX(TAB.OLD_Allowable_Parameter_Ver_Num) AS OLD_Allowable_Parameter_Ver_Num,
       MAX(TAB.NEW_Allowable_Parameter_Ver_Num) AS NEW_Allowable_Parameter_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Tag_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Tag_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Tag_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Tag_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Keyword_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Keyword_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Keyword_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Keyword_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Data_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Data_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Data_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Data_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Value_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Default_Value_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Value_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Default_Value_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Value_Num' THEN AT.OLD_VALUE
                    END AS OLD_Default_Value_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Value_Num' THEN AT.NEW_VALUE
                    END AS NEW_Default_Value_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Value_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Default_Value_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Value_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Default_Value_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Reserved_Word_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Reserved_Word_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Reserved_Word_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Reserved_Word_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parm_Domain_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parm_Domain_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Generate_Name_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Generate_Name_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Generate_Name_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Generate_Name_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Allowable_Parameter_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Allowable_Parameter_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Allowable_Parameter_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Allowable_Parameter_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'ALLOWABLE_PARAMETER') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_COMPONENT_PARAMETER_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_COMPONENT_PARAMETER_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_COMPONENT_PARAMETER_AUDIT
ON dbo.COMPONENT_PARAMETER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Component_Parameter_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'COMPONENT_PARAMETER';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Parameter_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Component_Parameter_ID,
                i.Component_Parameter_ID,
                'Component_Parameter_ID:'+ISNULL(CAST(i.Component_Parameter_ID as varchar),CAST(d.Component_Parameter_ID as varchar)),
                row_number() over (order by i.Component_Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Parameter_ID = i.Component_Parameter_ID
         Where CASE
                  WHEN i.Component_Parameter_ID <> d.Component_Parameter_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_ID,
                i.Product_Component_ID,
                'Component_Parameter_ID:'+ISNULL(CAST(i.Component_Parameter_ID as varchar),CAST(d.Component_Parameter_ID as varchar)),
                row_number() over (order by i.Component_Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Parameter_ID = i.Component_Parameter_ID
         Where CASE
                  WHEN i.Product_Component_ID <> d.Product_Component_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_ID,
                i.Parameter_ID,
                'Component_Parameter_ID:'+ISNULL(CAST(i.Component_Parameter_ID as varchar),CAST(d.Component_Parameter_ID as varchar)),
                row_number() over (order by i.Component_Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Parameter_ID = i.Component_Parameter_ID
         Where CASE
                  WHEN i.Parameter_ID <> d.Parameter_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Required_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Required_Fl,
                i.Required_Fl,
                'Component_Parameter_ID:'+ISNULL(CAST(i.Component_Parameter_ID as varchar),CAST(d.Component_Parameter_ID as varchar)),
                row_number() over (order by i.Component_Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Parameter_ID = i.Component_Parameter_ID
         Where CASE
                  WHEN i.Required_Fl <> d.Required_Fl THEN 1
                  WHEN i.Required_Fl IS NULL AND d.Required_Fl IS NOT NULL THEN 1
                  WHEN i.Required_Fl IS NOT NULL AND d.Required_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Parameter_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Component_Parameter_Ver_Num,
                i.Component_Parameter_Ver_Num,
                'Component_Parameter_ID:'+ISNULL(CAST(i.Component_Parameter_ID as varchar),CAST(d.Component_Parameter_ID as varchar)),
                row_number() over (order by i.Component_Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Parameter_ID = i.Component_Parameter_ID
         Where CASE
                  WHEN i.Component_Parameter_Ver_Num <> d.Component_Parameter_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Parameter_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Component_Parameter_ID,
                'Component_Parameter_ID:'+cast(i.Component_Parameter_ID as varchar),
                row_number() over (order by i.Component_Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_ID,
                'Component_Parameter_ID:'+cast(i.Component_Parameter_ID as varchar),
                row_number() over (order by i.Component_Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_ID,
                'Component_Parameter_ID:'+cast(i.Component_Parameter_ID as varchar),
                row_number() over (order by i.Component_Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Required_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Required_Fl,
                'Component_Parameter_ID:'+cast(i.Component_Parameter_ID as varchar),
                row_number() over (order by i.Component_Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Parameter_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Component_Parameter_Ver_Num,
                'Component_Parameter_ID:'+cast(i.Component_Parameter_ID as varchar),
                row_number() over (order by i.Component_Parameter_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Component_Parameter_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Component_Parameter_ID,
              NULL,
              'Component_Parameter_ID:'+cast(d.Component_Parameter_ID as varchar),
              row_number() over (order by d.Component_Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_ID,
              NULL,
              'Component_Parameter_ID:'+cast(d.Component_Parameter_ID as varchar),
              row_number() over (order by d.Component_Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_ID,
              NULL,
              'Component_Parameter_ID:'+cast(d.Component_Parameter_ID as varchar),
              row_number() over (order by d.Component_Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Required_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Required_Fl,
              NULL,
              'Component_Parameter_ID:'+cast(d.Component_Parameter_ID as varchar),
              row_number() over (order by d.Component_Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Component_Parameter_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Component_Parameter_Ver_Num,
              NULL,
              'Component_Parameter_ID:'+cast(d.Component_Parameter_ID as varchar),
              row_number() over (order by d.Component_Parameter_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_COMPONENT_PARAMETER_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_COMPONENT_PARAMETER_AUDIT;
      PRINT 'VIEW dbo.vw_COMPONENT_PARAMETER_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_COMPONENT_PARAMETER_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Component_Parameter_ID) AS OLD_Component_Parameter_ID,
       MAX(TAB.NEW_Component_Parameter_ID) AS NEW_Component_Parameter_ID,
       MAX(TAB.OLD_Product_Component_ID) AS OLD_Product_Component_ID,
       MAX(TAB.NEW_Product_Component_ID) AS NEW_Product_Component_ID,
       MAX(TAB.OLD_Parameter_ID) AS OLD_Parameter_ID,
       MAX(TAB.NEW_Parameter_ID) AS NEW_Parameter_ID,
       MAX(TAB.OLD_Required_Fl) AS OLD_Required_Fl,
       MAX(TAB.NEW_Required_Fl) AS NEW_Required_Fl,
       MAX(TAB.OLD_Component_Parameter_Ver_Num) AS OLD_Component_Parameter_Ver_Num,
       MAX(TAB.NEW_Component_Parameter_Ver_Num) AS NEW_Component_Parameter_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Parameter_ID' THEN AT.OLD_VALUE
                    END AS OLD_Component_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Parameter_ID' THEN AT.NEW_VALUE
                    END AS NEW_Component_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Required_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Required_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Required_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Required_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Parameter_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Component_Parameter_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Parameter_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Component_Parameter_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'COMPONENT_PARAMETER') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_CONTACT_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_CONTACT_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_CONTACT_AUDIT
ON dbo.CONTACT
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Contact_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'CONTACT';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Contact_ID,
                i.Contact_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Contact_ID <> d.Contact_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_Type_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Contact_Type_ID,
                i.Contact_Type_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Contact_Type_ID <> d.Contact_Type_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_ID,
                i.Product_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Product_ID <> d.Product_ID THEN 1
                  WHEN i.Product_ID IS NULL AND d.Product_ID IS NOT NULL THEN 1
                  WHEN i.Product_ID IS NOT NULL AND d.Product_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  WHEN i.Organization_ID IS NULL AND d.Organization_ID IS NOT NULL THEN 1
                  WHEN i.Organization_ID IS NOT NULL AND d.Organization_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.People_ID,
                i.People_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.People_ID <> d.People_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Installation_ID,
                i.Product_Installation_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Product_Installation_ID <> d.Product_Installation_ID THEN 1
                  WHEN i.Product_Installation_ID IS NULL AND d.Product_Installation_ID IS NOT NULL THEN 1
                  WHEN i.Product_Installation_ID IS NOT NULL AND d.Product_Installation_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_ID,
                i.Schedule_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Schedule_ID <> d.Schedule_ID THEN 1
                  WHEN i.Schedule_ID IS NULL AND d.Schedule_ID IS NOT NULL THEN 1
                  WHEN i.Schedule_ID IS NOT NULL AND d.Schedule_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Instance_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Instance_ID,
                i.Task_Instance_ID,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Task_Instance_ID <> d.Task_Instance_ID THEN 1
                  WHEN i.Task_Instance_ID IS NULL AND d.Task_Instance_ID IS NOT NULL THEN 1
                  WHEN i.Task_Instance_ID IS NOT NULL AND d.Task_Instance_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_Method_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Contact_Method_Cd,
                i.Contact_Method_Cd,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Contact_Method_Cd <> d.Contact_Method_Cd THEN 1
                  WHEN i.Contact_Method_Cd IS NULL AND d.Contact_Method_Cd IS NOT NULL THEN 1
                  WHEN i.Contact_Method_Cd IS NOT NULL AND d.Contact_Method_Cd IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Contact_Ver_Num,
                i.Contact_Ver_Num,
                'Contact_ID:'+ISNULL(CAST(i.Contact_ID as varchar),CAST(d.Contact_ID as varchar)),
                row_number() over (order by i.Contact_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Contact_ID = i.Contact_ID
         Where CASE
                  WHEN i.Contact_Ver_Num <> d.Contact_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Contact_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_Type_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Contact_Type_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.People_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Installation_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Instance_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Instance_ID,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_Method_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Contact_Method_Cd,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Contact_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Contact_Ver_Num,
                'Contact_ID:'+cast(i.Contact_ID as varchar),
                row_number() over (order by i.Contact_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Contact_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Contact_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Contact_Type_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Contact_Type_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'People_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.People_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Installation_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Installation_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Instance_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Instance_ID,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Contact_Method_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Contact_Method_Cd,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Contact_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Contact_Ver_Num,
              NULL,
              'Contact_ID:'+cast(d.Contact_ID as varchar),
              row_number() over (order by d.Contact_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_CONTACT_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_CONTACT_AUDIT;
      PRINT 'VIEW dbo.vw_CONTACT_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_CONTACT_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Contact_ID) AS OLD_Contact_ID,
       MAX(TAB.NEW_Contact_ID) AS NEW_Contact_ID,
       MAX(TAB.OLD_Contact_Type_ID) AS OLD_Contact_Type_ID,
       MAX(TAB.NEW_Contact_Type_ID) AS NEW_Contact_Type_ID,
       MAX(TAB.OLD_Product_ID) AS OLD_Product_ID,
       MAX(TAB.NEW_Product_ID) AS NEW_Product_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_People_ID) AS OLD_People_ID,
       MAX(TAB.NEW_People_ID) AS NEW_People_ID,
       MAX(TAB.OLD_Product_Installation_ID) AS OLD_Product_Installation_ID,
       MAX(TAB.NEW_Product_Installation_ID) AS NEW_Product_Installation_ID,
       MAX(TAB.OLD_Schedule_ID) AS OLD_Schedule_ID,
       MAX(TAB.NEW_Schedule_ID) AS NEW_Schedule_ID,
       MAX(TAB.OLD_Task_Instance_ID) AS OLD_Task_Instance_ID,
       MAX(TAB.NEW_Task_Instance_ID) AS NEW_Task_Instance_ID,
       MAX(TAB.OLD_Contact_Method_Cd) AS OLD_Contact_Method_Cd,
       MAX(TAB.NEW_Contact_Method_Cd) AS NEW_Contact_Method_Cd,
       MAX(TAB.OLD_Contact_Ver_Num) AS OLD_Contact_Ver_Num,
       MAX(TAB.NEW_Contact_Ver_Num) AS NEW_Contact_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_ID' THEN AT.OLD_VALUE
                    END AS OLD_Contact_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_ID' THEN AT.NEW_VALUE
                    END AS NEW_Contact_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_Type_ID' THEN AT.OLD_VALUE
                    END AS OLD_Contact_Type_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_Type_ID' THEN AT.NEW_VALUE
                    END AS NEW_Contact_Type_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_ID' THEN AT.OLD_VALUE
                    END AS OLD_People_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_ID' THEN AT.NEW_VALUE
                    END AS NEW_People_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_ID' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_ID' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Instance_ID' THEN AT.OLD_VALUE
                    END AS OLD_Task_Instance_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Instance_ID' THEN AT.NEW_VALUE
                    END AS NEW_Task_Instance_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_Method_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Contact_Method_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_Method_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Contact_Method_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Contact_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Contact_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Contact_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'CONTACT') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_CREDENTIAL_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_CREDENTIAL_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_CREDENTIAL_AUDIT
ON dbo.CREDENTIAL
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Credential_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'CREDENTIAL';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Credential_ID,
                i.Credential_ID,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Credential_ID <> d.Credential_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Login_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Login_Nm,
                i.Login_Nm,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Login_Nm <> d.Login_Nm THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secret_Password_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Secret_Password_Tx,
                i.Secret_Password_Tx,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Secret_Password_Tx <> d.Secret_Password_Tx THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Installation_ID,
                i.Product_Installation_ID,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Product_Installation_ID <> d.Product_Installation_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Product_Installation_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Related_Product_Installation_ID,
                i.Related_Product_Installation_ID,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Related_Product_Installation_ID <> d.Related_Product_Installation_ID THEN 1
                  WHEN i.Related_Product_Installation_ID IS NULL AND d.Related_Product_Installation_ID IS NOT NULL THEN 1
                  WHEN i.Related_Product_Installation_ID IS NOT NULL AND d.Related_Product_Installation_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Credential_Type_Cd,
                i.Credential_Type_Cd,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Credential_Type_Cd <> d.Credential_Type_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_Abrv_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Credential_Abrv_Tx,
                i.Credential_Abrv_Tx,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Credential_Abrv_Tx <> d.Credential_Abrv_Tx THEN 1
                  WHEN i.Credential_Abrv_Tx IS NULL AND d.Credential_Abrv_Tx IS NOT NULL THEN 1
                  WHEN i.Credential_Abrv_Tx IS NOT NULL AND d.Credential_Abrv_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Credential_Ver_Num,
                i.Credential_Ver_Num,
                'Credential_ID:'+ISNULL(CAST(i.Credential_ID as varchar),CAST(d.Credential_ID as varchar)),
                row_number() over (order by i.Credential_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Credential_ID = i.Credential_ID
         Where CASE
                  WHEN i.Credential_Ver_Num <> d.Credential_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Credential_ID,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Login_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Login_Nm,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Secret_Password_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Secret_Password_Tx,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Installation_ID,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Product_Installation_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Related_Product_Installation_ID,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Credential_Type_Cd,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_Abrv_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Credential_Abrv_Tx,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Credential_Ver_Num,
                'Credential_ID:'+cast(i.Credential_ID as varchar),
                row_number() over (order by i.Credential_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Credential_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Credential_ID,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Login_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Login_Nm,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Secret_Password_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Secret_Password_Tx,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Installation_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Installation_ID,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Related_Product_Installation_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Related_Product_Installation_ID,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Credential_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Credential_Type_Cd,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Credential_Abrv_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Credential_Abrv_Tx,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Credential_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Credential_Ver_Num,
              NULL,
              'Credential_ID:'+cast(d.Credential_ID as varchar),
              row_number() over (order by d.Credential_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_CREDENTIAL_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_CREDENTIAL_AUDIT;
      PRINT 'VIEW dbo.vw_CREDENTIAL_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_CREDENTIAL_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Credential_ID) AS OLD_Credential_ID,
       MAX(TAB.NEW_Credential_ID) AS NEW_Credential_ID,
       MAX(TAB.OLD_Login_Nm) AS OLD_Login_Nm,
       MAX(TAB.NEW_Login_Nm) AS NEW_Login_Nm,
       MAX(TAB.OLD_Secret_Password_Tx) AS OLD_Secret_Password_Tx,
       MAX(TAB.NEW_Secret_Password_Tx) AS NEW_Secret_Password_Tx,
       MAX(TAB.OLD_Product_Installation_ID) AS OLD_Product_Installation_ID,
       MAX(TAB.NEW_Product_Installation_ID) AS NEW_Product_Installation_ID,
       MAX(TAB.OLD_Related_Product_Installation_ID) AS OLD_Related_Product_Installation_ID,
       MAX(TAB.NEW_Related_Product_Installation_ID) AS NEW_Related_Product_Installation_ID,
       MAX(TAB.OLD_Credential_Type_Cd) AS OLD_Credential_Type_Cd,
       MAX(TAB.NEW_Credential_Type_Cd) AS NEW_Credential_Type_Cd,
       MAX(TAB.OLD_Credential_Abrv_Tx) AS OLD_Credential_Abrv_Tx,
       MAX(TAB.NEW_Credential_Abrv_Tx) AS NEW_Credential_Abrv_Tx,
       MAX(TAB.OLD_Credential_Ver_Num) AS OLD_Credential_Ver_Num,
       MAX(TAB.NEW_Credential_Ver_Num) AS NEW_Credential_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_ID' THEN AT.OLD_VALUE
                    END AS OLD_Credential_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_ID' THEN AT.NEW_VALUE
                    END AS NEW_Credential_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Login_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Login_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Login_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Login_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secret_Password_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Secret_Password_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Secret_Password_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Secret_Password_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Product_Installation_ID' THEN AT.OLD_VALUE
                    END AS OLD_Related_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Product_Installation_ID' THEN AT.NEW_VALUE
                    END AS NEW_Related_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Credential_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Credential_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_Abrv_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Credential_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_Abrv_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Credential_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Credential_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Credential_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'CREDENTIAL') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_GENERATE_NAME_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_GENERATE_NAME_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_GENERATE_NAME_AUDIT
ON dbo.GENERATE_NAME
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Component_Order_Num int;
   DECLARE @Parameter_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'GENERATE_NAME';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_ID,
                i.Parameter_ID,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parameter_ID <> d.Parameter_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Order_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Component_Order_Num,
                i.Component_Order_Num,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Component_Order_Num <> d.Component_Order_Num THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  WHEN i.Organization_ID IS NULL AND d.Organization_ID IS NOT NULL THEN 1
                  WHEN i.Organization_ID IS NOT NULL AND d.Organization_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_ID,
                i.Product_ID,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Product_ID <> d.Product_ID THEN 1
                  WHEN i.Product_ID IS NULL AND d.Product_ID IS NOT NULL THEN 1
                  WHEN i.Product_ID IS NOT NULL AND d.Product_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  WHEN i.Server_ID IS NULL AND d.Server_ID IS NOT NULL THEN 1
                  WHEN i.Server_ID IS NOT NULL AND d.Server_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Credential_ID,
                i.Credential_ID,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Credential_ID <> d.Credential_ID THEN 1
                  WHEN i.Credential_ID IS NULL AND d.Credential_ID IS NOT NULL THEN 1
                  WHEN i.Credential_ID IS NOT NULL AND d.Credential_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Use_Constant_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Use_Constant_Fl,
                i.Use_Constant_Fl,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Use_Constant_Fl <> d.Use_Constant_Fl THEN 1
                  WHEN i.Use_Constant_Fl IS NULL AND d.Use_Constant_Fl IS NOT NULL THEN 1
                  WHEN i.Use_Constant_Fl IS NOT NULL AND d.Use_Constant_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Constant_Value_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Constant_Value_Tx,
                i.Constant_Value_Tx,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Constant_Value_Tx <> d.Constant_Value_Tx THEN 1
                  WHEN i.Constant_Value_Tx IS NULL AND d.Constant_Value_Tx IS NOT NULL THEN 1
                  WHEN i.Constant_Value_Tx IS NOT NULL AND d.Constant_Value_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Specified_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.User_Specified_Fl,
                i.User_Specified_Fl,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.User_Specified_Fl <> d.User_Specified_Fl THEN 1
                  WHEN i.User_Specified_Fl IS NULL AND d.User_Specified_Fl IS NOT NULL THEN 1
                  WHEN i.User_Specified_Fl IS NOT NULL AND d.User_Specified_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Specified_Length_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.User_Specified_Length_Num,
                i.User_Specified_Length_Num,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.User_Specified_Length_Num <> d.User_Specified_Length_Num THEN 1
                  WHEN i.User_Specified_Length_Num IS NULL AND d.User_Specified_Length_Num IS NOT NULL THEN 1
                  WHEN i.User_Specified_Length_Num IS NOT NULL AND d.User_Specified_Length_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parm_Domain_ID,
                i.Parm_Domain_ID,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Parm_Domain_ID <> d.Parm_Domain_ID THEN 1
                  WHEN i.Parm_Domain_ID IS NULL AND d.Parm_Domain_ID IS NOT NULL THEN 1
                  WHEN i.Parm_Domain_ID IS NOT NULL AND d.Parm_Domain_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Generate_Name_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Generate_Name_Ver_Num,
                i.Generate_Name_Ver_Num,
                'Component_Order_Num:'+ISNULL(CAST(i.Component_Order_Num as varchar),CAST(d.Component_Order_Num as varchar))+'|'+'Parameter_ID:'+ISNULL(CAST(i.Parameter_ID as varchar),CAST(d.Parameter_ID as varchar)),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Component_Order_Num = i.Component_Order_Num and d.Parameter_ID = i.Parameter_ID
         Where CASE
                  WHEN i.Generate_Name_Ver_Num <> d.Generate_Name_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_ID,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Order_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Component_Order_Num,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_ID,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Credential_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Credential_ID,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Use_Constant_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Use_Constant_Fl,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Constant_Value_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Constant_Value_Tx,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Specified_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.User_Specified_Fl,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'User_Specified_Length_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.User_Specified_Length_Num,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parm_Domain_ID,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Generate_Name_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Generate_Name_Ver_Num,
                'Component_Order_Num:'+cast(i.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(i.Parameter_ID as varchar),
                row_number() over (order by i.Component_Order_Num,i.Parameter_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_ID,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Component_Order_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Component_Order_Num,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_ID,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Credential_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Credential_ID,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Use_Constant_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Use_Constant_Fl,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Constant_Value_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Constant_Value_Tx,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'User_Specified_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.User_Specified_Fl,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'User_Specified_Length_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.User_Specified_Length_Num,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parm_Domain_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parm_Domain_ID,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Generate_Name_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Generate_Name_Ver_Num,
              NULL,
              'Component_Order_Num:'+cast(d.Component_Order_Num as varchar)+'|'+'Parameter_ID:'+cast(d.Parameter_ID as varchar),
              row_number() over (order by d.Component_Order_Num,d.Parameter_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_GENERATE_NAME_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_GENERATE_NAME_AUDIT;
      PRINT 'VIEW dbo.vw_GENERATE_NAME_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_GENERATE_NAME_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Parameter_ID) AS OLD_Parameter_ID,
       MAX(TAB.NEW_Parameter_ID) AS NEW_Parameter_ID,
       MAX(TAB.OLD_Component_Order_Num) AS OLD_Component_Order_Num,
       MAX(TAB.NEW_Component_Order_Num) AS NEW_Component_Order_Num,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Product_ID) AS OLD_Product_ID,
       MAX(TAB.NEW_Product_ID) AS NEW_Product_ID,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Credential_ID) AS OLD_Credential_ID,
       MAX(TAB.NEW_Credential_ID) AS NEW_Credential_ID,
       MAX(TAB.OLD_Use_Constant_Fl) AS OLD_Use_Constant_Fl,
       MAX(TAB.NEW_Use_Constant_Fl) AS NEW_Use_Constant_Fl,
       MAX(TAB.OLD_Constant_Value_Tx) AS OLD_Constant_Value_Tx,
       MAX(TAB.NEW_Constant_Value_Tx) AS NEW_Constant_Value_Tx,
       MAX(TAB.OLD_User_Specified_Fl) AS OLD_User_Specified_Fl,
       MAX(TAB.NEW_User_Specified_Fl) AS NEW_User_Specified_Fl,
       MAX(TAB.OLD_User_Specified_Length_Num) AS OLD_User_Specified_Length_Num,
       MAX(TAB.NEW_User_Specified_Length_Num) AS NEW_User_Specified_Length_Num,
       MAX(TAB.OLD_Parm_Domain_ID) AS OLD_Parm_Domain_ID,
       MAX(TAB.NEW_Parm_Domain_ID) AS NEW_Parm_Domain_ID,
       MAX(TAB.OLD_Generate_Name_Ver_Num) AS OLD_Generate_Name_Ver_Num,
       MAX(TAB.NEW_Generate_Name_Ver_Num) AS NEW_Generate_Name_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Order_Num' THEN AT.OLD_VALUE
                    END AS OLD_Component_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Order_Num' THEN AT.NEW_VALUE
                    END AS NEW_Component_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_ID' THEN AT.OLD_VALUE
                    END AS OLD_Credential_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Credential_ID' THEN AT.NEW_VALUE
                    END AS NEW_Credential_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Use_Constant_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Use_Constant_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Use_Constant_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Use_Constant_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Constant_Value_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Constant_Value_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Constant_Value_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Constant_Value_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Specified_Fl' THEN AT.OLD_VALUE
                    END AS OLD_User_Specified_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Specified_Fl' THEN AT.NEW_VALUE
                    END AS NEW_User_Specified_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Specified_Length_Num' THEN AT.OLD_VALUE
                    END AS OLD_User_Specified_Length_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'User_Specified_Length_Num' THEN AT.NEW_VALUE
                    END AS NEW_User_Specified_Length_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parm_Domain_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parm_Domain_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Generate_Name_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Generate_Name_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Generate_Name_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Generate_Name_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'GENERATE_NAME') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_INSTALL_USER_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_INSTALL_USER_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_INSTALL_USER_AUDIT
ON dbo.INSTALL_USER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Install_User_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'INSTALL_USER';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_User_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Install_User_ID,
                i.Install_User_ID,
                'Install_User_ID:'+ISNULL(CAST(i.Install_User_ID as varchar),CAST(d.Install_User_ID as varchar)),
                row_number() over (order by i.Install_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Install_User_ID = i.Install_User_ID
         Where CASE
                  WHEN i.Install_User_ID <> d.Install_User_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.People_ID,
                i.People_ID,
                'Install_User_ID:'+ISNULL(CAST(i.Install_User_ID as varchar),CAST(d.Install_User_ID as varchar)),
                row_number() over (order by i.Install_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Install_User_ID = i.Install_User_ID
         Where CASE
                  WHEN i.People_ID <> d.People_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Environment_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Environment_Type_Cd,
                i.Environment_Type_Cd,
                'Install_User_ID:'+ISNULL(CAST(i.Install_User_ID as varchar),CAST(d.Install_User_ID as varchar)),
                row_number() over (order by i.Install_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Install_User_ID = i.Install_User_ID
         Where CASE
                  WHEN i.Environment_Type_Cd <> d.Environment_Type_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_ID,
                i.Product_ID,
                'Install_User_ID:'+ISNULL(CAST(i.Install_User_ID as varchar),CAST(d.Install_User_ID as varchar)),
                row_number() over (order by i.Install_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Install_User_ID = i.Install_User_ID
         Where CASE
                  WHEN i.Product_ID <> d.Product_ID THEN 1
                  WHEN i.Product_ID IS NULL AND d.Product_ID IS NOT NULL THEN 1
                  WHEN i.Product_ID IS NOT NULL AND d.Product_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_User_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Install_User_Ver_Num,
                i.Install_User_Ver_Num,
                'Install_User_ID:'+ISNULL(CAST(i.Install_User_ID as varchar),CAST(d.Install_User_ID as varchar)),
                row_number() over (order by i.Install_User_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Install_User_ID = i.Install_User_ID
         Where CASE
                  WHEN i.Install_User_Ver_Num <> d.Install_User_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_User_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Install_User_ID,
                'Install_User_ID:'+cast(i.Install_User_ID as varchar),
                row_number() over (order by i.Install_User_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.People_ID,
                'Install_User_ID:'+cast(i.Install_User_ID as varchar),
                row_number() over (order by i.Install_User_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Environment_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Environment_Type_Cd,
                'Install_User_ID:'+cast(i.Install_User_ID as varchar),
                row_number() over (order by i.Install_User_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_ID,
                'Install_User_ID:'+cast(i.Install_User_ID as varchar),
                row_number() over (order by i.Install_User_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_User_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Install_User_Ver_Num,
                'Install_User_ID:'+cast(i.Install_User_ID as varchar),
                row_number() over (order by i.Install_User_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Install_User_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Install_User_ID,
              NULL,
              'Install_User_ID:'+cast(d.Install_User_ID as varchar),
              row_number() over (order by d.Install_User_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'People_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.People_ID,
              NULL,
              'Install_User_ID:'+cast(d.Install_User_ID as varchar),
              row_number() over (order by d.Install_User_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Environment_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Environment_Type_Cd,
              NULL,
              'Install_User_ID:'+cast(d.Install_User_ID as varchar),
              row_number() over (order by d.Install_User_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_ID,
              NULL,
              'Install_User_ID:'+cast(d.Install_User_ID as varchar),
              row_number() over (order by d.Install_User_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Install_User_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Install_User_Ver_Num,
              NULL,
              'Install_User_ID:'+cast(d.Install_User_ID as varchar),
              row_number() over (order by d.Install_User_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_INSTALL_USER_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_INSTALL_USER_AUDIT;
      PRINT 'VIEW dbo.vw_INSTALL_USER_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_INSTALL_USER_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Install_User_ID) AS OLD_Install_User_ID,
       MAX(TAB.NEW_Install_User_ID) AS NEW_Install_User_ID,
       MAX(TAB.OLD_People_ID) AS OLD_People_ID,
       MAX(TAB.NEW_People_ID) AS NEW_People_ID,
       MAX(TAB.OLD_Environment_Type_Cd) AS OLD_Environment_Type_Cd,
       MAX(TAB.NEW_Environment_Type_Cd) AS NEW_Environment_Type_Cd,
       MAX(TAB.OLD_Product_ID) AS OLD_Product_ID,
       MAX(TAB.NEW_Product_ID) AS NEW_Product_ID,
       MAX(TAB.OLD_Install_User_Ver_Num) AS OLD_Install_User_Ver_Num,
       MAX(TAB.NEW_Install_User_Ver_Num) AS NEW_Install_User_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_User_ID' THEN AT.OLD_VALUE
                    END AS OLD_Install_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_User_ID' THEN AT.NEW_VALUE
                    END AS NEW_Install_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_ID' THEN AT.OLD_VALUE
                    END AS OLD_People_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_ID' THEN AT.NEW_VALUE
                    END AS NEW_People_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Environment_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Environment_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Environment_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Environment_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_User_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Install_User_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_User_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Install_User_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'INSTALL_USER') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_JOB_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_JOB_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_JOB_AUDIT
ON dbo.JOB
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Job_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'JOB';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_ID,
                i.Job_ID,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Job_ID <> d.Job_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_Nm,
                i.Job_Nm,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Job_Nm <> d.Job_Nm THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_Dsc,
                i.Job_Dsc,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Job_Dsc <> d.Job_Dsc THEN 1
                  WHEN i.Job_Dsc IS NULL AND d.Job_Dsc IS NOT NULL THEN 1
                  WHEN i.Job_Dsc IS NOT NULL AND d.Job_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_ID,
                i.Product_Component_ID,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Product_Component_ID <> d.Product_Component_ID THEN 1
                  WHEN i.Product_Component_ID IS NULL AND d.Product_Component_ID IS NOT NULL THEN 1
                  WHEN i.Product_Component_ID IS NOT NULL AND d.Product_Component_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Prior_Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Prior_Product_Component_ID,
                i.Prior_Product_Component_ID,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Prior_Product_Component_ID <> d.Prior_Product_Component_ID THEN 1
                  WHEN i.Prior_Product_Component_ID IS NULL AND d.Prior_Product_Component_ID IS NOT NULL THEN 1
                  WHEN i.Prior_Product_Component_ID IS NOT NULL AND d.Prior_Product_Component_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_Type_Cd,
                i.Job_Type_Cd,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Job_Type_Cd <> d.Job_Type_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_Ver_Num,
                i.Job_Ver_Num,
                'Job_ID:'+ISNULL(CAST(i.Job_ID as varchar),CAST(d.Job_ID as varchar)),
                row_number() over (order by i.Job_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Job_ID = i.Job_ID
         Where CASE
                  WHEN i.Job_Ver_Num <> d.Job_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_ID,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_Nm,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_Dsc,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_ID,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Prior_Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Prior_Product_Component_ID,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_Type_Cd,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_Ver_Num,
                'Job_ID:'+cast(i.Job_ID as varchar),
                row_number() over (order by i.Job_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_ID,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_Nm,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_Dsc,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_ID,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Prior_Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Prior_Product_Component_ID,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_Type_Cd,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_Ver_Num,
              NULL,
              'Job_ID:'+cast(d.Job_ID as varchar),
              row_number() over (order by d.Job_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_JOB_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_JOB_AUDIT;
      PRINT 'VIEW dbo.vw_JOB_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_JOB_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Job_ID) AS OLD_Job_ID,
       MAX(TAB.NEW_Job_ID) AS NEW_Job_ID,
       MAX(TAB.OLD_Job_Nm) AS OLD_Job_Nm,
       MAX(TAB.NEW_Job_Nm) AS NEW_Job_Nm,
       MAX(TAB.OLD_Job_Dsc) AS OLD_Job_Dsc,
       MAX(TAB.NEW_Job_Dsc) AS NEW_Job_Dsc,
       MAX(TAB.OLD_Product_Component_ID) AS OLD_Product_Component_ID,
       MAX(TAB.NEW_Product_Component_ID) AS NEW_Product_Component_ID,
       MAX(TAB.OLD_Prior_Product_Component_ID) AS OLD_Prior_Product_Component_ID,
       MAX(TAB.NEW_Prior_Product_Component_ID) AS NEW_Prior_Product_Component_ID,
       MAX(TAB.OLD_Job_Type_Cd) AS OLD_Job_Type_Cd,
       MAX(TAB.NEW_Job_Type_Cd) AS NEW_Job_Type_Cd,
       MAX(TAB.OLD_Job_Ver_Num) AS OLD_Job_Ver_Num,
       MAX(TAB.NEW_Job_Ver_Num) AS NEW_Job_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_ID' THEN AT.OLD_VALUE
                    END AS OLD_Job_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_ID' THEN AT.NEW_VALUE
                    END AS NEW_Job_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Job_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Job_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Job_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Job_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Prior_Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Prior_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Prior_Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Prior_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Job_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Job_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Job_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Job_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'JOB') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_ORGANIZATION_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_ORGANIZATION_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_ORGANIZATION_AUDIT
ON dbo.ORGANIZATION
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

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
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
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

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_Nm,
                i.Organization_Nm,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_Nm <> d.Organization_Nm THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_Dsc,
                i.Organization_Dsc,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_Dsc <> d.Organization_Dsc THEN 1
                  WHEN i.Organization_Dsc IS NULL AND d.Organization_Dsc IS NOT NULL THEN 1
                  WHEN i.Organization_Dsc IS NOT NULL AND d.Organization_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Client_T3K_Master_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Client_T3K_Master_ID,
                i.Client_T3K_Master_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Client_T3K_Master_ID <> d.Client_T3K_Master_ID THEN 1
                  WHEN i.Client_T3K_Master_ID IS NULL AND d.Client_T3K_Master_ID IS NOT NULL THEN 1
                  WHEN i.Client_T3K_Master_ID IS NOT NULL AND d.Client_T3K_Master_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Client_T3K_Supervisor_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Client_T3K_Supervisor_ID,
                i.Client_T3K_Supervisor_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Client_T3K_Supervisor_ID <> d.Client_T3K_Supervisor_ID THEN 1
                  WHEN i.Client_T3K_Supervisor_ID IS NULL AND d.Client_T3K_Supervisor_ID IS NOT NULL THEN 1
                  WHEN i.Client_T3K_Supervisor_ID IS NOT NULL AND d.Client_T3K_Supervisor_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'T3K_Shared_Master_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.T3K_Shared_Master_Fl,
                i.T3K_Shared_Master_Fl,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.T3K_Shared_Master_Fl <> d.T3K_Shared_Master_Fl THEN 1
                  WHEN i.T3K_Shared_Master_Fl IS NULL AND d.T3K_Shared_Master_Fl IS NOT NULL THEN 1
                  WHEN i.T3K_Shared_Master_Fl IS NOT NULL AND d.T3K_Shared_Master_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Mainframe_System_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Mainframe_System_Nm,
                i.Mainframe_System_Nm,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Mainframe_System_Nm <> d.Mainframe_System_Nm THEN 1
                  WHEN i.Mainframe_System_Nm IS NULL AND d.Mainframe_System_Nm IS NOT NULL THEN 1
                  WHEN i.Mainframe_System_Nm IS NOT NULL AND d.Mainframe_System_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'ADABAS_DB_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.ADABAS_DB_Num,
                i.ADABAS_DB_Num,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.ADABAS_DB_Num <> d.ADABAS_DB_Num THEN 1
                  WHEN i.ADABAS_DB_Num IS NULL AND d.ADABAS_DB_Num IS NOT NULL THEN 1
                  WHEN i.ADABAS_DB_Num IS NOT NULL AND d.ADABAS_DB_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'SEI_Client_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.SEI_Client_ID,
                i.SEI_Client_ID,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.SEI_Client_ID <> d.SEI_Client_ID THEN 1
                  WHEN i.SEI_Client_ID IS NULL AND d.SEI_Client_ID IS NOT NULL THEN 1
                  WHEN i.SEI_Client_ID IS NOT NULL AND d.SEI_Client_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Active_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_Active_Fl,
                i.Organization_Active_Fl,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_Active_Fl <> d.Organization_Active_Fl THEN 1
                  WHEN i.Organization_Active_Fl IS NULL AND d.Organization_Active_Fl IS NOT NULL THEN 1
                  WHEN i.Organization_Active_Fl IS NOT NULL AND d.Organization_Active_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Abrv_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_Abrv_Tx,
                i.Organization_Abrv_Tx,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_Abrv_Tx <> d.Organization_Abrv_Tx THEN 1
                  WHEN i.Organization_Abrv_Tx IS NULL AND d.Organization_Abrv_Tx IS NOT NULL THEN 1
                  WHEN i.Organization_Abrv_Tx IS NOT NULL AND d.Organization_Abrv_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Naming_Abrv_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_Naming_Abrv_Tx,
                i.Job_Naming_Abrv_Tx,
                'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Job_Naming_Abrv_Tx <> d.Job_Naming_Abrv_Tx THEN 1
                  WHEN i.Job_Naming_Abrv_Tx IS NULL AND d.Job_Naming_Abrv_Tx IS NOT NULL THEN 1
                  WHEN i.Job_Naming_Abrv_Tx IS NOT NULL AND d.Job_Naming_Abrv_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
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
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
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

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_Nm,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_Dsc,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Client_T3K_Master_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Client_T3K_Master_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Client_T3K_Supervisor_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Client_T3K_Supervisor_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'T3K_Shared_Master_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.T3K_Shared_Master_Fl,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Mainframe_System_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Mainframe_System_Nm,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'ADABAS_DB_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.ADABAS_DB_Num,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'SEI_Client_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.SEI_Client_ID,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Active_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_Active_Fl,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_Abrv_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_Abrv_Tx,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_Naming_Abrv_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_Naming_Abrv_Tx,
                'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
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
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
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

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_Nm,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_Dsc,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Client_T3K_Master_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Client_T3K_Master_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Client_T3K_Supervisor_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Client_T3K_Supervisor_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'T3K_Shared_Master_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.T3K_Shared_Master_Fl,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Mainframe_System_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Mainframe_System_Nm,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'ADABAS_DB_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.ADABAS_DB_Num,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'SEI_Client_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.SEI_Client_ID,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_Active_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_Active_Fl,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_Abrv_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_Abrv_Tx,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_Naming_Abrv_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_Naming_Abrv_Tx,
              NULL,
              'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
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
    WHERE table_schema = N'dbo' and table_name = N'vw_ORGANIZATION_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_ORGANIZATION_AUDIT;
      PRINT 'VIEW dbo.vw_ORGANIZATION_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_ORGANIZATION_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Organization_Nm) AS OLD_Organization_Nm,
       MAX(TAB.NEW_Organization_Nm) AS NEW_Organization_Nm,
       MAX(TAB.OLD_Organization_Dsc) AS OLD_Organization_Dsc,
       MAX(TAB.NEW_Organization_Dsc) AS NEW_Organization_Dsc,
       MAX(TAB.OLD_Client_T3K_Master_ID) AS OLD_Client_T3K_Master_ID,
       MAX(TAB.NEW_Client_T3K_Master_ID) AS NEW_Client_T3K_Master_ID,
       MAX(TAB.OLD_Client_T3K_Supervisor_ID) AS OLD_Client_T3K_Supervisor_ID,
       MAX(TAB.NEW_Client_T3K_Supervisor_ID) AS NEW_Client_T3K_Supervisor_ID,
       MAX(TAB.OLD_T3K_Shared_Master_Fl) AS OLD_T3K_Shared_Master_Fl,
       MAX(TAB.NEW_T3K_Shared_Master_Fl) AS NEW_T3K_Shared_Master_Fl,
       MAX(TAB.OLD_Mainframe_System_Nm) AS OLD_Mainframe_System_Nm,
       MAX(TAB.NEW_Mainframe_System_Nm) AS NEW_Mainframe_System_Nm,
       MAX(TAB.OLD_ADABAS_DB_Num) AS OLD_ADABAS_DB_Num,
       MAX(TAB.NEW_ADABAS_DB_Num) AS NEW_ADABAS_DB_Num,
       MAX(TAB.OLD_SEI_Client_ID) AS OLD_SEI_Client_ID,
       MAX(TAB.NEW_SEI_Client_ID) AS NEW_SEI_Client_ID,
       MAX(TAB.OLD_Organization_Active_Fl) AS OLD_Organization_Active_Fl,
       MAX(TAB.NEW_Organization_Active_Fl) AS NEW_Organization_Active_Fl,
       MAX(TAB.OLD_Organization_Abrv_Tx) AS OLD_Organization_Abrv_Tx,
       MAX(TAB.NEW_Organization_Abrv_Tx) AS NEW_Organization_Abrv_Tx,
       MAX(TAB.OLD_Job_Naming_Abrv_Tx) AS OLD_Job_Naming_Abrv_Tx,
       MAX(TAB.NEW_Job_Naming_Abrv_Tx) AS NEW_Job_Naming_Abrv_Tx,
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
                       WHEN 'Organization_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Client_T3K_Master_ID' THEN AT.OLD_VALUE
                    END AS OLD_Client_T3K_Master_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Client_T3K_Master_ID' THEN AT.NEW_VALUE
                    END AS NEW_Client_T3K_Master_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Client_T3K_Supervisor_ID' THEN AT.OLD_VALUE
                    END AS OLD_Client_T3K_Supervisor_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Client_T3K_Supervisor_ID' THEN AT.NEW_VALUE
                    END AS NEW_Client_T3K_Supervisor_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'T3K_Shared_Master_Fl' THEN AT.OLD_VALUE
                    END AS OLD_T3K_Shared_Master_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'T3K_Shared_Master_Fl' THEN AT.NEW_VALUE
                    END AS NEW_T3K_Shared_Master_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Mainframe_System_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Mainframe_System_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Mainframe_System_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Mainframe_System_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'ADABAS_DB_Num' THEN AT.OLD_VALUE
                    END AS OLD_ADABAS_DB_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'ADABAS_DB_Num' THEN AT.NEW_VALUE
                    END AS NEW_ADABAS_DB_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'SEI_Client_ID' THEN AT.OLD_VALUE
                    END AS OLD_SEI_Client_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'SEI_Client_ID' THEN AT.NEW_VALUE
                    END AS NEW_SEI_Client_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Active_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Active_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Active_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Active_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Abrv_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Abrv_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Naming_Abrv_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Job_Naming_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_Naming_Abrv_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Job_Naming_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Organization_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Organization_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'ORGANIZATION') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PARAMETER_USAGE_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PARAMETER_USAGE_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PARAMETER_USAGE_AUDIT
ON dbo.PARAMETER_USAGE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Parameter_Usage_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PARAMETER_USAGE';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Usage_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Usage_ID,
                i.Parameter_Usage_ID,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Parameter_Usage_ID <> d.Parameter_Usage_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_ID,
                i.Parameter_ID,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Parameter_ID <> d.Parameter_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  WHEN i.Server_ID IS NULL AND d.Server_ID IS NOT NULL THEN 1
                  WHEN i.Server_ID IS NOT NULL AND d.Server_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  WHEN i.Organization_ID IS NULL AND d.Organization_ID IS NOT NULL THEN 1
                  WHEN i.Organization_ID IS NOT NULL AND d.Organization_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Value_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Value_Tx,
                i.Parameter_Value_Tx,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Parameter_Value_Tx <> d.Parameter_Value_Tx THEN 1
                  WHEN i.Parameter_Value_Tx IS NULL AND d.Parameter_Value_Tx IS NOT NULL THEN 1
                  WHEN i.Parameter_Value_Tx IS NOT NULL AND d.Parameter_Value_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Value_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Value_Num,
                i.Parameter_Value_Num,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Parameter_Value_Num <> d.Parameter_Value_Num THEN 1
                  WHEN i.Parameter_Value_Num IS NULL AND d.Parameter_Value_Num IS NOT NULL THEN 1
                  WHEN i.Parameter_Value_Num IS NOT NULL AND d.Parameter_Value_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Value_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Value_Fl,
                i.Parameter_Value_Fl,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Parameter_Value_Fl <> d.Parameter_Value_Fl THEN 1
                  WHEN i.Parameter_Value_Fl IS NULL AND d.Parameter_Value_Fl IS NOT NULL THEN 1
                  WHEN i.Parameter_Value_Fl IS NOT NULL AND d.Parameter_Value_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Usage_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parameter_Usage_Ver_Num,
                i.Parameter_Usage_Ver_Num,
                'Parameter_Usage_ID:'+ISNULL(CAST(i.Parameter_Usage_ID as varchar),CAST(d.Parameter_Usage_ID as varchar)),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parameter_Usage_ID = i.Parameter_Usage_ID
         Where CASE
                  WHEN i.Parameter_Usage_Ver_Num <> d.Parameter_Usage_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Usage_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Usage_ID,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_ID,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Value_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Value_Tx,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Value_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Value_Num,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Value_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Value_Fl,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parameter_Usage_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parameter_Usage_Ver_Num,
                'Parameter_Usage_ID:'+cast(i.Parameter_Usage_ID as varchar),
                row_number() over (order by i.Parameter_Usage_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Usage_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Usage_ID,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_ID,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Value_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Value_Tx,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Value_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Value_Num,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Value_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Value_Fl,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parameter_Usage_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parameter_Usage_Ver_Num,
              NULL,
              'Parameter_Usage_ID:'+cast(d.Parameter_Usage_ID as varchar),
              row_number() over (order by d.Parameter_Usage_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PARAMETER_USAGE_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PARAMETER_USAGE_AUDIT;
      PRINT 'VIEW dbo.vw_PARAMETER_USAGE_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PARAMETER_USAGE_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Parameter_Usage_ID) AS OLD_Parameter_Usage_ID,
       MAX(TAB.NEW_Parameter_Usage_ID) AS NEW_Parameter_Usage_ID,
       MAX(TAB.OLD_Parameter_ID) AS OLD_Parameter_ID,
       MAX(TAB.NEW_Parameter_ID) AS NEW_Parameter_ID,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Parameter_Value_Tx) AS OLD_Parameter_Value_Tx,
       MAX(TAB.NEW_Parameter_Value_Tx) AS NEW_Parameter_Value_Tx,
       MAX(TAB.OLD_Parameter_Value_Num) AS OLD_Parameter_Value_Num,
       MAX(TAB.NEW_Parameter_Value_Num) AS NEW_Parameter_Value_Num,
       MAX(TAB.OLD_Parameter_Value_Fl) AS OLD_Parameter_Value_Fl,
       MAX(TAB.NEW_Parameter_Value_Fl) AS NEW_Parameter_Value_Fl,
       MAX(TAB.OLD_Parameter_Usage_Ver_Num) AS OLD_Parameter_Usage_Ver_Num,
       MAX(TAB.NEW_Parameter_Usage_Ver_Num) AS NEW_Parameter_Usage_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Usage_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Usage_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Usage_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Usage_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Value_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Value_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Value_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Value_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Value_Num' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Value_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Value_Num' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Value_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Value_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Value_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Value_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Value_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Usage_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Parameter_Usage_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parameter_Usage_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Parameter_Usage_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PARAMETER_USAGE') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PARM_DOMAIN_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PARM_DOMAIN_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PARM_DOMAIN_AUDIT
ON dbo.PARM_DOMAIN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Parm_Domain_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PARM_DOMAIN';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parm_Domain_ID,
                i.Parm_Domain_ID,
                'Parm_Domain_ID:'+ISNULL(CAST(i.Parm_Domain_ID as varchar),CAST(d.Parm_Domain_ID as varchar)),
                row_number() over (order by i.Parm_Domain_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parm_Domain_ID = i.Parm_Domain_ID
         Where CASE
                  WHEN i.Parm_Domain_ID <> d.Parm_Domain_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parm_Domain_Nm,
                i.Parm_Domain_Nm,
                'Parm_Domain_ID:'+ISNULL(CAST(i.Parm_Domain_ID as varchar),CAST(d.Parm_Domain_ID as varchar)),
                row_number() over (order by i.Parm_Domain_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parm_Domain_ID = i.Parm_Domain_ID
         Where CASE
                  WHEN i.Parm_Domain_Nm <> d.Parm_Domain_Nm THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Parm_Domain_Ver_Num,
                i.Parm_Domain_Ver_Num,
                'Parm_Domain_ID:'+ISNULL(CAST(i.Parm_Domain_ID as varchar),CAST(d.Parm_Domain_ID as varchar)),
                row_number() over (order by i.Parm_Domain_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Parm_Domain_ID = i.Parm_Domain_ID
         Where CASE
                  WHEN i.Parm_Domain_Ver_Num <> d.Parm_Domain_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parm_Domain_ID,
                'Parm_Domain_ID:'+cast(i.Parm_Domain_ID as varchar),
                row_number() over (order by i.Parm_Domain_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parm_Domain_Nm,
                'Parm_Domain_ID:'+cast(i.Parm_Domain_ID as varchar),
                row_number() over (order by i.Parm_Domain_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Parm_Domain_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Parm_Domain_Ver_Num,
                'Parm_Domain_ID:'+cast(i.Parm_Domain_ID as varchar),
                row_number() over (order by i.Parm_Domain_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parm_Domain_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parm_Domain_ID,
              NULL,
              'Parm_Domain_ID:'+cast(d.Parm_Domain_ID as varchar),
              row_number() over (order by d.Parm_Domain_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parm_Domain_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parm_Domain_Nm,
              NULL,
              'Parm_Domain_ID:'+cast(d.Parm_Domain_ID as varchar),
              row_number() over (order by d.Parm_Domain_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Parm_Domain_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Parm_Domain_Ver_Num,
              NULL,
              'Parm_Domain_ID:'+cast(d.Parm_Domain_ID as varchar),
              row_number() over (order by d.Parm_Domain_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PARM_DOMAIN_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PARM_DOMAIN_AUDIT;
      PRINT 'VIEW dbo.vw_PARM_DOMAIN_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PARM_DOMAIN_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Parm_Domain_ID) AS OLD_Parm_Domain_ID,
       MAX(TAB.NEW_Parm_Domain_ID) AS NEW_Parm_Domain_ID,
       MAX(TAB.OLD_Parm_Domain_Nm) AS OLD_Parm_Domain_Nm,
       MAX(TAB.NEW_Parm_Domain_Nm) AS NEW_Parm_Domain_Nm,
       MAX(TAB.OLD_Parm_Domain_Ver_Num) AS OLD_Parm_Domain_Ver_Num,
       MAX(TAB.NEW_Parm_Domain_Ver_Num) AS NEW_Parm_Domain_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_ID' THEN AT.OLD_VALUE
                    END AS OLD_Parm_Domain_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_ID' THEN AT.NEW_VALUE
                    END AS NEW_Parm_Domain_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Parm_Domain_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Parm_Domain_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Parm_Domain_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Parm_Domain_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Parm_Domain_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PARM_DOMAIN') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PEOPLE_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PEOPLE_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PEOPLE_AUDIT
ON dbo.PEOPLE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @People_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PEOPLE';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.People_ID,
                i.People_ID,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.People_ID <> d.People_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Phone_Number_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Phone_Number_Tx,
                i.Phone_Number_Tx,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.Phone_Number_Tx <> d.Phone_Number_Tx THEN 1
                  WHEN i.Phone_Number_Tx IS NULL AND d.Phone_Number_Tx IS NOT NULL THEN 1
                  WHEN i.Phone_Number_Tx IS NOT NULL AND d.Phone_Number_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Alternate_Phone_Number_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Alternate_Phone_Number_Tx,
                i.Alternate_Phone_Number_Tx,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.Alternate_Phone_Number_Tx <> d.Alternate_Phone_Number_Tx THEN 1
                  WHEN i.Alternate_Phone_Number_Tx IS NULL AND d.Alternate_Phone_Number_Tx IS NOT NULL THEN 1
                  WHEN i.Alternate_Phone_Number_Tx IS NOT NULL AND d.Alternate_Phone_Number_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.People_Nm,
                i.People_Nm,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.People_Nm <> d.People_Nm THEN 1
                  WHEN i.People_Nm IS NULL AND d.People_Nm IS NOT NULL THEN 1
                  WHEN i.People_Nm IS NOT NULL AND d.People_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Email_Address_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Email_Address_Tx,
                i.Email_Address_Tx,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.Email_Address_Tx <> d.Email_Address_Tx THEN 1
                  WHEN i.Email_Address_Tx IS NULL AND d.Email_Address_Tx IS NOT NULL THEN 1
                  WHEN i.Email_Address_Tx IS NOT NULL AND d.Email_Address_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Virtual_User_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Virtual_User_Fl,
                i.Virtual_User_Fl,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.Virtual_User_Fl <> d.Virtual_User_Fl THEN 1
                  WHEN i.Virtual_User_Fl IS NULL AND d.Virtual_User_Fl IS NOT NULL THEN 1
                  WHEN i.Virtual_User_Fl IS NOT NULL AND d.Virtual_User_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Group_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Group_Fl,
                i.Group_Fl,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.Group_Fl <> d.Group_Fl THEN 1
                  WHEN i.Group_Fl IS NULL AND d.Group_Fl IS NOT NULL THEN 1
                  WHEN i.Group_Fl IS NOT NULL AND d.Group_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'SEI_Internal_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.SEI_Internal_Fl,
                i.SEI_Internal_Fl,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.SEI_Internal_Fl <> d.SEI_Internal_Fl THEN 1
                  WHEN i.SEI_Internal_Fl IS NULL AND d.SEI_Internal_Fl IS NOT NULL THEN 1
                  WHEN i.SEI_Internal_Fl IS NOT NULL AND d.SEI_Internal_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.People_Ver_Num,
                i.People_Ver_Num,
                'People_ID:'+ISNULL(CAST(i.People_ID as varchar),CAST(d.People_ID as varchar)),
                row_number() over (order by i.People_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.People_ID = i.People_ID
         Where CASE
                  WHEN i.People_Ver_Num <> d.People_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.People_ID,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Phone_Number_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Phone_Number_Tx,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Alternate_Phone_Number_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Alternate_Phone_Number_Tx,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.People_Nm,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Email_Address_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Email_Address_Tx,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Virtual_User_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Virtual_User_Fl,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Group_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Group_Fl,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'SEI_Internal_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.SEI_Internal_Fl,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'People_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.People_Ver_Num,
                'People_ID:'+cast(i.People_ID as varchar),
                row_number() over (order by i.People_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'People_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.People_ID,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Phone_Number_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Phone_Number_Tx,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Alternate_Phone_Number_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Alternate_Phone_Number_Tx,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'People_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.People_Nm,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Email_Address_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Email_Address_Tx,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Virtual_User_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Virtual_User_Fl,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Group_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Group_Fl,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'SEI_Internal_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.SEI_Internal_Fl,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'People_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.People_Ver_Num,
              NULL,
              'People_ID:'+cast(d.People_ID as varchar),
              row_number() over (order by d.People_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PEOPLE_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PEOPLE_AUDIT;
      PRINT 'VIEW dbo.vw_PEOPLE_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PEOPLE_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_People_ID) AS OLD_People_ID,
       MAX(TAB.NEW_People_ID) AS NEW_People_ID,
       MAX(TAB.OLD_Phone_Number_Tx) AS OLD_Phone_Number_Tx,
       MAX(TAB.NEW_Phone_Number_Tx) AS NEW_Phone_Number_Tx,
       MAX(TAB.OLD_Alternate_Phone_Number_Tx) AS OLD_Alternate_Phone_Number_Tx,
       MAX(TAB.NEW_Alternate_Phone_Number_Tx) AS NEW_Alternate_Phone_Number_Tx,
       MAX(TAB.OLD_People_Nm) AS OLD_People_Nm,
       MAX(TAB.NEW_People_Nm) AS NEW_People_Nm,
       MAX(TAB.OLD_Email_Address_Tx) AS OLD_Email_Address_Tx,
       MAX(TAB.NEW_Email_Address_Tx) AS NEW_Email_Address_Tx,
       MAX(TAB.OLD_Virtual_User_Fl) AS OLD_Virtual_User_Fl,
       MAX(TAB.NEW_Virtual_User_Fl) AS NEW_Virtual_User_Fl,
       MAX(TAB.OLD_Group_Fl) AS OLD_Group_Fl,
       MAX(TAB.NEW_Group_Fl) AS NEW_Group_Fl,
       MAX(TAB.OLD_SEI_Internal_Fl) AS OLD_SEI_Internal_Fl,
       MAX(TAB.NEW_SEI_Internal_Fl) AS NEW_SEI_Internal_Fl,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_People_Ver_Num) AS OLD_People_Ver_Num,
       MAX(TAB.NEW_People_Ver_Num) AS NEW_People_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_ID' THEN AT.OLD_VALUE
                    END AS OLD_People_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_ID' THEN AT.NEW_VALUE
                    END AS NEW_People_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Phone_Number_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Phone_Number_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Phone_Number_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Phone_Number_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Alternate_Phone_Number_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Alternate_Phone_Number_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Alternate_Phone_Number_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Alternate_Phone_Number_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_Nm' THEN AT.OLD_VALUE
                    END AS OLD_People_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_Nm' THEN AT.NEW_VALUE
                    END AS NEW_People_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Email_Address_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Email_Address_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Email_Address_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Email_Address_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Virtual_User_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Virtual_User_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Virtual_User_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Virtual_User_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Group_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Group_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Group_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Group_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'SEI_Internal_Fl' THEN AT.OLD_VALUE
                    END AS OLD_SEI_Internal_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'SEI_Internal_Fl' THEN AT.NEW_VALUE
                    END AS NEW_SEI_Internal_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_People_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'People_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_People_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PEOPLE') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PRODUCT_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PRODUCT_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PRODUCT_AUDIT
ON dbo.PRODUCT
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Product_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PRODUCT';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_ID,
                i.Product_ID,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Product_ID <> d.Product_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Nm,
                i.Product_Nm,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Product_Nm <> d.Product_Nm THEN 1
                  WHEN i.Product_Nm IS NULL AND d.Product_Nm IS NOT NULL THEN 1
                  WHEN i.Product_Nm IS NOT NULL AND d.Product_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Type_Cd,
                i.Product_Type_Cd,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Product_Type_Cd <> d.Product_Type_Cd THEN 1
                  WHEN i.Product_Type_Cd IS NULL AND d.Product_Type_Cd IS NOT NULL THEN 1
                  WHEN i.Product_Type_Cd IS NOT NULL AND d.Product_Type_Cd IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  WHEN i.Organization_ID IS NULL AND d.Organization_ID IS NOT NULL THEN 1
                  WHEN i.Organization_ID IS NOT NULL AND d.Organization_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Dsc,
                i.Product_Dsc,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Product_Dsc <> d.Product_Dsc THEN 1
                  WHEN i.Product_Dsc IS NULL AND d.Product_Dsc IS NOT NULL THEN 1
                  WHEN i.Product_Dsc IS NOT NULL AND d.Product_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Abrv_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Abrv_Tx,
                i.Product_Abrv_Tx,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Product_Abrv_Tx <> d.Product_Abrv_Tx THEN 1
                  WHEN i.Product_Abrv_Tx IS NULL AND d.Product_Abrv_Tx IS NOT NULL THEN 1
                  WHEN i.Product_Abrv_Tx IS NOT NULL AND d.Product_Abrv_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Ver_Num,
                i.Product_Ver_Num,
                'Product_ID:'+ISNULL(CAST(i.Product_ID as varchar),CAST(d.Product_ID as varchar)),
                row_number() over (order by i.Product_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_ID = i.Product_ID
         Where CASE
                  WHEN i.Product_Ver_Num <> d.Product_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_ID,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Nm,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Type_Cd,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Dsc,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Abrv_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Abrv_Tx,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Ver_Num,
                'Product_ID:'+cast(i.Product_ID as varchar),
                row_number() over (order by i.Product_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_ID,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Nm,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Type_Cd,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Dsc,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Abrv_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Abrv_Tx,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Ver_Num,
              NULL,
              'Product_ID:'+cast(d.Product_ID as varchar),
              row_number() over (order by d.Product_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PRODUCT_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PRODUCT_AUDIT;
      PRINT 'VIEW dbo.vw_PRODUCT_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PRODUCT_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Product_ID) AS OLD_Product_ID,
       MAX(TAB.NEW_Product_ID) AS NEW_Product_ID,
       MAX(TAB.OLD_Product_Nm) AS OLD_Product_Nm,
       MAX(TAB.NEW_Product_Nm) AS NEW_Product_Nm,
       MAX(TAB.OLD_Product_Type_Cd) AS OLD_Product_Type_Cd,
       MAX(TAB.NEW_Product_Type_Cd) AS NEW_Product_Type_Cd,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Product_Dsc) AS OLD_Product_Dsc,
       MAX(TAB.NEW_Product_Dsc) AS NEW_Product_Dsc,
       MAX(TAB.OLD_Product_Abrv_Tx) AS OLD_Product_Abrv_Tx,
       MAX(TAB.NEW_Product_Abrv_Tx) AS NEW_Product_Abrv_Tx,
       MAX(TAB.OLD_Product_Ver_Num) AS OLD_Product_Ver_Num,
       MAX(TAB.NEW_Product_Ver_Num) AS NEW_Product_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Product_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Product_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Product_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Product_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Product_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Product_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Abrv_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Product_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Abrv_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Product_Abrv_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Product_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Product_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PRODUCT') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PRODUCT_COMPATIBLE_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PRODUCT_COMPATIBLE_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PRODUCT_COMPATIBLE_AUDIT
ON dbo.PRODUCT_COMPATIBLE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Product_Component_ID int;
   DECLARE @Related_Product_Component_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PRODUCT_COMPATIBLE';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_ID,
                i.Product_Component_ID,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Related_Product_Component_ID:'+ISNULL(CAST(i.Related_Product_Component_ID as varchar),CAST(d.Related_Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Related_Product_Component_ID = i.Related_Product_Component_ID
         Where CASE
                  WHEN i.Product_Component_ID <> d.Product_Component_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Related_Product_Component_ID,
                i.Related_Product_Component_ID,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Related_Product_Component_ID:'+ISNULL(CAST(i.Related_Product_Component_ID as varchar),CAST(d.Related_Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Related_Product_Component_ID = i.Related_Product_Component_ID
         Where CASE
                  WHEN i.Related_Product_Component_ID <> d.Related_Product_Component_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Dependent_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Dependent_Fl,
                i.Product_Dependent_Fl,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Related_Product_Component_ID:'+ISNULL(CAST(i.Related_Product_Component_ID as varchar),CAST(d.Related_Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Related_Product_Component_ID = i.Related_Product_Component_ID
         Where CASE
                  WHEN i.Product_Dependent_Fl <> d.Product_Dependent_Fl THEN 1
                  WHEN i.Product_Dependent_Fl IS NULL AND d.Product_Dependent_Fl IS NOT NULL THEN 1
                  WHEN i.Product_Dependent_Fl IS NOT NULL AND d.Product_Dependent_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Preferred_Component_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Preferred_Component_Fl,
                i.Preferred_Component_Fl,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Related_Product_Component_ID:'+ISNULL(CAST(i.Related_Product_Component_ID as varchar),CAST(d.Related_Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Related_Product_Component_ID = i.Related_Product_Component_ID
         Where CASE
                  WHEN i.Preferred_Component_Fl <> d.Preferred_Component_Fl THEN 1
                  WHEN i.Preferred_Component_Fl IS NULL AND d.Preferred_Component_Fl IS NOT NULL THEN 1
                  WHEN i.Preferred_Component_Fl IS NOT NULL AND d.Preferred_Component_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Compatible_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Compatible_Ver_Num,
                i.Product_Compatible_Ver_Num,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Related_Product_Component_ID:'+ISNULL(CAST(i.Related_Product_Component_ID as varchar),CAST(d.Related_Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Related_Product_Component_ID = i.Related_Product_Component_ID
         Where CASE
                  WHEN i.Product_Compatible_Ver_Num <> d.Product_Compatible_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_ID,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(i.Related_Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Related_Product_Component_ID,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(i.Related_Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Dependent_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Dependent_Fl,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(i.Related_Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Preferred_Component_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Preferred_Component_Fl,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(i.Related_Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Compatible_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Compatible_Ver_Num,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(i.Related_Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Related_Product_Component_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_ID,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(d.Related_Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Related_Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Related_Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Related_Product_Component_ID,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(d.Related_Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Related_Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Dependent_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Dependent_Fl,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(d.Related_Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Related_Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Preferred_Component_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Preferred_Component_Fl,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(d.Related_Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Related_Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Compatible_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Compatible_Ver_Num,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Related_Product_Component_ID:'+cast(d.Related_Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Related_Product_Component_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PRODUCT_COMPATIBLE_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PRODUCT_COMPATIBLE_AUDIT;
      PRINT 'VIEW dbo.vw_PRODUCT_COMPATIBLE_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PRODUCT_COMPATIBLE_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Product_Component_ID) AS OLD_Product_Component_ID,
       MAX(TAB.NEW_Product_Component_ID) AS NEW_Product_Component_ID,
       MAX(TAB.OLD_Related_Product_Component_ID) AS OLD_Related_Product_Component_ID,
       MAX(TAB.NEW_Related_Product_Component_ID) AS NEW_Related_Product_Component_ID,
       MAX(TAB.OLD_Product_Dependent_Fl) AS OLD_Product_Dependent_Fl,
       MAX(TAB.NEW_Product_Dependent_Fl) AS NEW_Product_Dependent_Fl,
       MAX(TAB.OLD_Preferred_Component_Fl) AS OLD_Preferred_Component_Fl,
       MAX(TAB.NEW_Preferred_Component_Fl) AS NEW_Preferred_Component_Fl,
       MAX(TAB.OLD_Product_Compatible_Ver_Num) AS OLD_Product_Compatible_Ver_Num,
       MAX(TAB.NEW_Product_Compatible_Ver_Num) AS NEW_Product_Compatible_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Related_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Related_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Dependent_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Product_Dependent_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Dependent_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Product_Dependent_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Preferred_Component_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Preferred_Component_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Preferred_Component_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Preferred_Component_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Compatible_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Product_Compatible_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Compatible_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Product_Compatible_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PRODUCT_COMPATIBLE') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PRODUCT_COMPONENT_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PRODUCT_COMPONENT_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PRODUCT_COMPONENT_AUDIT
ON dbo.PRODUCT_COMPONENT
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Product_Component_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PRODUCT_COMPONENT';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_ID,
                i.Product_Component_ID,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Product_Component_ID <> d.Product_Component_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Version_ID,
                i.Product_Version_ID,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Product_Version_ID <> d.Product_Version_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_Nm,
                i.Product_Component_Nm,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Product_Component_Nm <> d.Product_Component_Nm THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Component_Type_Cd,
                i.Component_Type_Cd,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Component_Type_Cd <> d.Component_Type_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Availability_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Availability_Dt,
                i.Availability_Dt,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Availability_Dt <> d.Availability_Dt THEN 1
                  WHEN i.Availability_Dt IS NULL AND d.Availability_Dt IS NOT NULL THEN 1
                  WHEN i.Availability_Dt IS NOT NULL AND d.Availability_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'In_Production_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.In_Production_Fl,
                i.In_Production_Fl,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.In_Production_Fl <> d.In_Production_Fl THEN 1
                  WHEN i.In_Production_Fl IS NULL AND d.In_Production_Fl IS NOT NULL THEN 1
                  WHEN i.In_Production_Fl IS NOT NULL AND d.In_Production_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_Dsc,
                i.Product_Component_Dsc,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Product_Component_Dsc <> d.Product_Component_Dsc THEN 1
                  WHEN i.Product_Component_Dsc IS NULL AND d.Product_Component_Dsc IS NOT NULL THEN 1
                  WHEN i.Product_Component_Dsc IS NOT NULL AND d.Product_Component_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Template_URL_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Template_URL_Tx,
                i.Template_URL_Tx,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Template_URL_Tx <> d.Template_URL_Tx THEN 1
                  WHEN i.Template_URL_Tx IS NULL AND d.Template_URL_Tx IS NOT NULL THEN 1
                  WHEN i.Template_URL_Tx IS NOT NULL AND d.Template_URL_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Order_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Order_Num,
                i.Order_Num,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Order_Num <> d.Order_Num THEN 1
                  WHEN i.Order_Num IS NULL AND d.Order_Num IS NOT NULL THEN 1
                  WHEN i.Order_Num IS NOT NULL AND d.Order_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_Ver_Num,
                i.Product_Component_Ver_Num,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar)),
                row_number() over (order by i.Product_Component_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID
         Where CASE
                  WHEN i.Product_Component_Ver_Num <> d.Product_Component_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_ID,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Version_ID,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_Nm,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Component_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Component_Type_Cd,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Availability_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Availability_Dt,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'In_Production_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.In_Production_Fl,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_Dsc,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Template_URL_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Template_URL_Tx,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Order_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Order_Num,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_Ver_Num,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar),
                row_number() over (order by i.Product_Component_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_ID,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Version_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Version_ID,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_Nm,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Component_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Component_Type_Cd,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Availability_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Availability_Dt,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'In_Production_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.In_Production_Fl,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_Dsc,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Template_URL_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Template_URL_Tx,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Order_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Order_Num,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_Ver_Num,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar),
              row_number() over (order by d.Product_Component_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PRODUCT_COMPONENT_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PRODUCT_COMPONENT_AUDIT;
      PRINT 'VIEW dbo.vw_PRODUCT_COMPONENT_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PRODUCT_COMPONENT_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Product_Component_ID) AS OLD_Product_Component_ID,
       MAX(TAB.NEW_Product_Component_ID) AS NEW_Product_Component_ID,
       MAX(TAB.OLD_Product_Version_ID) AS OLD_Product_Version_ID,
       MAX(TAB.NEW_Product_Version_ID) AS NEW_Product_Version_ID,
       MAX(TAB.OLD_Product_Component_Nm) AS OLD_Product_Component_Nm,
       MAX(TAB.NEW_Product_Component_Nm) AS NEW_Product_Component_Nm,
       MAX(TAB.OLD_Component_Type_Cd) AS OLD_Component_Type_Cd,
       MAX(TAB.NEW_Component_Type_Cd) AS NEW_Component_Type_Cd,
       MAX(TAB.OLD_Availability_Dt) AS OLD_Availability_Dt,
       MAX(TAB.NEW_Availability_Dt) AS NEW_Availability_Dt,
       MAX(TAB.OLD_In_Production_Fl) AS OLD_In_Production_Fl,
       MAX(TAB.NEW_In_Production_Fl) AS NEW_In_Production_Fl,
       MAX(TAB.OLD_Product_Component_Dsc) AS OLD_Product_Component_Dsc,
       MAX(TAB.NEW_Product_Component_Dsc) AS NEW_Product_Component_Dsc,
       MAX(TAB.OLD_Template_URL_Tx) AS OLD_Template_URL_Tx,
       MAX(TAB.NEW_Template_URL_Tx) AS NEW_Template_URL_Tx,
       MAX(TAB.OLD_Order_Num) AS OLD_Order_Num,
       MAX(TAB.NEW_Order_Num) AS NEW_Order_Num,
       MAX(TAB.OLD_Product_Component_Ver_Num) AS OLD_Product_Component_Ver_Num,
       MAX(TAB.NEW_Product_Component_Ver_Num) AS NEW_Product_Component_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Version_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Version_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Component_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Component_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Component_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Availability_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Availability_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Availability_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Availability_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'In_Production_Fl' THEN AT.OLD_VALUE
                    END AS OLD_In_Production_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'In_Production_Fl' THEN AT.NEW_VALUE
                    END AS NEW_In_Production_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Template_URL_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Template_URL_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Template_URL_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Template_URL_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Order_Num' THEN AT.OLD_VALUE
                    END AS OLD_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Order_Num' THEN AT.NEW_VALUE
                    END AS NEW_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PRODUCT_COMPONENT') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PRODUCT_ELIGIBILITY_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PRODUCT_ELIGIBILITY_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PRODUCT_ELIGIBILITY_AUDIT
ON dbo.PRODUCT_ELIGIBILITY
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Product_Component_ID int;
   DECLARE @Organization_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PRODUCT_ELIGIBILITY';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_ID,
                i.Product_Component_ID,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Product_Component_ID <> d.Product_Component_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Eligible_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Eligible_Dt,
                i.Eligible_Dt,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Eligible_Dt <> d.Eligible_Dt THEN 1
                  WHEN i.Eligible_Dt IS NULL AND d.Eligible_Dt IS NOT NULL THEN 1
                  WHEN i.Eligible_Dt IS NOT NULL AND d.Eligible_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Termination_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Termination_Dt,
                i.Termination_Dt,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Termination_Dt <> d.Termination_Dt THEN 1
                  WHEN i.Termination_Dt IS NULL AND d.Termination_Dt IS NOT NULL THEN 1
                  WHEN i.Termination_Dt IS NOT NULL AND d.Termination_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Eligibility_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Eligibility_Ver_Num,
                i.Product_Eligibility_Ver_Num,
                'Product_Component_ID:'+ISNULL(CAST(i.Product_Component_ID as varchar),CAST(d.Product_Component_ID as varchar))+'|'+'Organization_ID:'+ISNULL(CAST(i.Organization_ID as varchar),CAST(d.Organization_ID as varchar)),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Component_ID = i.Product_Component_ID and d.Organization_ID = i.Organization_ID
         Where CASE
                  WHEN i.Product_Eligibility_Ver_Num <> d.Product_Eligibility_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_ID,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Eligible_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Eligible_Dt,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Termination_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Termination_Dt,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Eligibility_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Eligibility_Ver_Num,
                'Product_Component_ID:'+cast(i.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(i.Organization_ID as varchar),
                row_number() over (order by i.Product_Component_ID,i.Organization_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_ID,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Eligible_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Eligible_Dt,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Termination_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Termination_Dt,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Organization_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Eligibility_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Eligibility_Ver_Num,
              NULL,
              'Product_Component_ID:'+cast(d.Product_Component_ID as varchar)+'|'+'Organization_ID:'+cast(d.Organization_ID as varchar),
              row_number() over (order by d.Product_Component_ID,d.Organization_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PRODUCT_ELIGIBILITY_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PRODUCT_ELIGIBILITY_AUDIT;
      PRINT 'VIEW dbo.vw_PRODUCT_ELIGIBILITY_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PRODUCT_ELIGIBILITY_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Product_Component_ID) AS OLD_Product_Component_ID,
       MAX(TAB.NEW_Product_Component_ID) AS NEW_Product_Component_ID,
       MAX(TAB.OLD_Eligible_Dt) AS OLD_Eligible_Dt,
       MAX(TAB.NEW_Eligible_Dt) AS NEW_Eligible_Dt,
       MAX(TAB.OLD_Termination_Dt) AS OLD_Termination_Dt,
       MAX(TAB.NEW_Termination_Dt) AS NEW_Termination_Dt,
       MAX(TAB.OLD_Product_Eligibility_Ver_Num) AS OLD_Product_Eligibility_Ver_Num,
       MAX(TAB.NEW_Product_Eligibility_Ver_Num) AS NEW_Product_Eligibility_Ver_Num
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
                       WHEN 'Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Eligible_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Eligible_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Eligible_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Eligible_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Termination_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Termination_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Termination_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Termination_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Eligibility_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Product_Eligibility_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Eligibility_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Product_Eligibility_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PRODUCT_ELIGIBILITY') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PRODUCT_INSTALLATION_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PRODUCT_INSTALLATION_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PRODUCT_INSTALLATION_AUDIT
ON dbo.PRODUCT_INSTALLATION
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Product_Installation_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PRODUCT_INSTALLATION';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Installation_ID,
                i.Product_Installation_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Product_Installation_ID <> d.Product_Installation_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Installation_Nm,
                i.Product_Installation_Nm,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Product_Installation_Nm <> d.Product_Installation_Nm THEN 1
                  WHEN i.Product_Installation_Nm IS NULL AND d.Product_Installation_Nm IS NOT NULL THEN 1
                  WHEN i.Product_Installation_Nm IS NOT NULL AND d.Product_Installation_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  WHEN i.Server_ID IS NULL AND d.Server_ID IS NOT NULL THEN 1
                  WHEN i.Server_ID IS NOT NULL AND d.Server_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Environment_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Environment_Type_Cd,
                i.Environment_Type_Cd,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Environment_Type_Cd <> d.Environment_Type_Cd THEN 1
                  WHEN i.Environment_Type_Cd IS NULL AND d.Environment_Type_Cd IS NOT NULL THEN 1
                  WHEN i.Environment_Type_Cd IS NOT NULL AND d.Environment_Type_Cd IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  WHEN i.Organization_ID IS NULL AND d.Organization_ID IS NOT NULL THEN 1
                  WHEN i.Organization_ID IS NOT NULL AND d.Organization_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Component_ID,
                i.Product_Component_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Product_Component_ID <> d.Product_Component_ID THEN 1
                  WHEN i.Product_Component_ID IS NULL AND d.Product_Component_ID IS NOT NULL THEN 1
                  WHEN i.Product_Component_ID IS NOT NULL AND d.Product_Component_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Install_Dt,
                i.Install_Dt,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Install_Dt <> d.Install_Dt THEN 1
                  WHEN i.Install_Dt IS NULL AND d.Install_Dt IS NOT NULL THEN 1
                  WHEN i.Install_Dt IS NOT NULL AND d.Install_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_State_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Install_State_Cd,
                i.Install_State_Cd,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Install_State_Cd <> d.Install_State_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Purchase_Order_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Purchase_Order_ID,
                i.Purchase_Order_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Purchase_Order_ID <> d.Purchase_Order_ID THEN 1
                  WHEN i.Purchase_Order_ID IS NULL AND d.Purchase_Order_ID IS NOT NULL THEN 1
                  WHEN i.Purchase_Order_ID IS NOT NULL AND d.Purchase_Order_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'License_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.License_ID,
                i.License_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.License_ID <> d.License_ID THEN 1
                  WHEN i.License_ID IS NULL AND d.License_ID IS NOT NULL THEN 1
                  WHEN i.License_ID IS NOT NULL AND d.License_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'URL_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.URL_Tx,
                i.URL_Tx,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.URL_Tx <> d.URL_Tx THEN 1
                  WHEN i.URL_Tx IS NULL AND d.URL_Tx IS NOT NULL THEN 1
                  WHEN i.URL_Tx IS NOT NULL AND d.URL_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Port_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Port_Num,
                i.Port_Num,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Port_Num <> d.Port_Num THEN 1
                  WHEN i.Port_Num IS NULL AND d.Port_Num IS NOT NULL THEN 1
                  WHEN i.Port_Num IS NOT NULL AND d.Port_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_User_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Install_User_ID,
                i.Install_User_ID,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Install_User_ID <> d.Install_User_ID THEN 1
                  WHEN i.Install_User_ID IS NULL AND d.Install_User_ID IS NOT NULL THEN 1
                  WHEN i.Install_User_ID IS NOT NULL AND d.Install_User_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'License_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.License_Type_Cd,
                i.License_Type_Cd,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.License_Type_Cd <> d.License_Type_Cd THEN 1
                  WHEN i.License_Type_Cd IS NULL AND d.License_Type_Cd IS NOT NULL THEN 1
                  WHEN i.License_Type_Cd IS NOT NULL AND d.License_Type_Cd IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Installation_Ver_Num,
                i.Product_Installation_Ver_Num,
                'Product_Installation_ID:'+ISNULL(CAST(i.Product_Installation_ID as varchar),CAST(d.Product_Installation_ID as varchar)),
                row_number() over (order by i.Product_Installation_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Installation_ID = i.Product_Installation_ID
         Where CASE
                  WHEN i.Product_Installation_Ver_Num <> d.Product_Installation_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Installation_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Installation_Nm,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Environment_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Environment_Type_Cd,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Component_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Component_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Install_Dt,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_State_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Install_State_Cd,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Purchase_Order_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Purchase_Order_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'License_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.License_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'URL_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.URL_Tx,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Port_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Port_Num,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Install_User_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Install_User_ID,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'License_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.License_Type_Cd,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Installation_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Installation_Ver_Num,
                'Product_Installation_ID:'+cast(i.Product_Installation_ID as varchar),
                row_number() over (order by i.Product_Installation_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Installation_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Installation_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Installation_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Installation_Nm,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Environment_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Environment_Type_Cd,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Component_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Component_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Install_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Install_Dt,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Install_State_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Install_State_Cd,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Purchase_Order_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Purchase_Order_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'License_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.License_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'URL_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.URL_Tx,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Port_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Port_Num,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Install_User_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Install_User_ID,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'License_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.License_Type_Cd,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Installation_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Installation_Ver_Num,
              NULL,
              'Product_Installation_ID:'+cast(d.Product_Installation_ID as varchar),
              row_number() over (order by d.Product_Installation_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PRODUCT_INSTALLATION_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PRODUCT_INSTALLATION_AUDIT;
      PRINT 'VIEW dbo.vw_PRODUCT_INSTALLATION_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PRODUCT_INSTALLATION_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Product_Installation_ID) AS OLD_Product_Installation_ID,
       MAX(TAB.NEW_Product_Installation_ID) AS NEW_Product_Installation_ID,
       MAX(TAB.OLD_Product_Installation_Nm) AS OLD_Product_Installation_Nm,
       MAX(TAB.NEW_Product_Installation_Nm) AS NEW_Product_Installation_Nm,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Environment_Type_Cd) AS OLD_Environment_Type_Cd,
       MAX(TAB.NEW_Environment_Type_Cd) AS NEW_Environment_Type_Cd,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Product_Component_ID) AS OLD_Product_Component_ID,
       MAX(TAB.NEW_Product_Component_ID) AS NEW_Product_Component_ID,
       MAX(TAB.OLD_Install_Dt) AS OLD_Install_Dt,
       MAX(TAB.NEW_Install_Dt) AS NEW_Install_Dt,
       MAX(TAB.OLD_Install_State_Cd) AS OLD_Install_State_Cd,
       MAX(TAB.NEW_Install_State_Cd) AS NEW_Install_State_Cd,
       MAX(TAB.OLD_Purchase_Order_ID) AS OLD_Purchase_Order_ID,
       MAX(TAB.NEW_Purchase_Order_ID) AS NEW_Purchase_Order_ID,
       MAX(TAB.OLD_License_ID) AS OLD_License_ID,
       MAX(TAB.NEW_License_ID) AS NEW_License_ID,
       MAX(TAB.OLD_URL_Tx) AS OLD_URL_Tx,
       MAX(TAB.NEW_URL_Tx) AS NEW_URL_Tx,
       MAX(TAB.OLD_Port_Num) AS OLD_Port_Num,
       MAX(TAB.NEW_Port_Num) AS NEW_Port_Num,
       MAX(TAB.OLD_Install_User_ID) AS OLD_Install_User_ID,
       MAX(TAB.NEW_Install_User_ID) AS NEW_Install_User_ID,
       MAX(TAB.OLD_License_Type_Cd) AS OLD_License_Type_Cd,
       MAX(TAB.NEW_License_Type_Cd) AS NEW_License_Type_Cd,
       MAX(TAB.OLD_Product_Installation_Ver_Num) AS OLD_Product_Installation_Ver_Num,
       MAX(TAB.NEW_Product_Installation_Ver_Num) AS NEW_Product_Installation_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Installation_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Product_Installation_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Product_Installation_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Environment_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Environment_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Environment_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Environment_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Component_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Component_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Install_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Install_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_State_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Install_State_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_State_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Install_State_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Purchase_Order_ID' THEN AT.OLD_VALUE
                    END AS OLD_Purchase_Order_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Purchase_Order_ID' THEN AT.NEW_VALUE
                    END AS NEW_Purchase_Order_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'License_ID' THEN AT.OLD_VALUE
                    END AS OLD_License_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'License_ID' THEN AT.NEW_VALUE
                    END AS NEW_License_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'URL_Tx' THEN AT.OLD_VALUE
                    END AS OLD_URL_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'URL_Tx' THEN AT.NEW_VALUE
                    END AS NEW_URL_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Port_Num' THEN AT.OLD_VALUE
                    END AS OLD_Port_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Port_Num' THEN AT.NEW_VALUE
                    END AS NEW_Port_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_User_ID' THEN AT.OLD_VALUE
                    END AS OLD_Install_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Install_User_ID' THEN AT.NEW_VALUE
                    END AS NEW_Install_User_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'License_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_License_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'License_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_License_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Product_Installation_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Installation_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Product_Installation_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PRODUCT_INSTALLATION') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_PRODUCT_VERSION_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_PRODUCT_VERSION_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_PRODUCT_VERSION_AUDIT
ON dbo.PRODUCT_VERSION
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Product_Version_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'PRODUCT_VERSION';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Version_ID,
                i.Product_Version_ID,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Product_Version_ID <> d.Product_Version_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_ID,
                i.Product_ID,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Product_ID <> d.Product_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Version_Tag_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Version_Tag_Tx,
                i.Version_Tag_Tx,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Version_Tag_Tx <> d.Version_Tag_Tx THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Patch_Level_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Patch_Level_Tx,
                i.Patch_Level_Tx,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Patch_Level_Tx <> d.Patch_Level_Tx THEN 1
                  WHEN i.Patch_Level_Tx IS NULL AND d.Patch_Level_Tx IS NOT NULL THEN 1
                  WHEN i.Patch_Level_Tx IS NOT NULL AND d.Patch_Level_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Version_Nm,
                i.Product_Version_Nm,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Product_Version_Nm <> d.Product_Version_Nm THEN 1
                  WHEN i.Product_Version_Nm IS NULL AND d.Product_Version_Nm IS NOT NULL THEN 1
                  WHEN i.Product_Version_Nm IS NOT NULL AND d.Product_Version_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Version_Dt,
                i.Product_Version_Dt,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Product_Version_Dt <> d.Product_Version_Dt THEN 1
                  WHEN i.Product_Version_Dt IS NULL AND d.Product_Version_Dt IS NOT NULL THEN 1
                  WHEN i.Product_Version_Dt IS NOT NULL AND d.Product_Version_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Version_Dsc,
                i.Product_Version_Dsc,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Product_Version_Dsc <> d.Product_Version_Dsc THEN 1
                  WHEN i.Product_Version_Dsc IS NULL AND d.Product_Version_Dsc IS NOT NULL THEN 1
                  WHEN i.Product_Version_Dsc IS NOT NULL AND d.Product_Version_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Product_Version_Ver_Num,
                i.Product_Version_Ver_Num,
                'Product_Version_ID:'+ISNULL(CAST(i.Product_Version_ID as varchar),CAST(d.Product_Version_ID as varchar)),
                row_number() over (order by i.Product_Version_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Product_Version_ID = i.Product_Version_ID
         Where CASE
                  WHEN i.Product_Version_Ver_Num <> d.Product_Version_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Version_ID,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_ID,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Version_Tag_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Version_Tag_Tx,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Patch_Level_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Patch_Level_Tx,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Version_Nm,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Version_Dt,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Version_Dsc,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Product_Version_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Product_Version_Ver_Num,
                'Product_Version_ID:'+cast(i.Product_Version_ID as varchar),
                row_number() over (order by i.Product_Version_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Version_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Version_ID,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_ID,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Version_Tag_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Version_Tag_Tx,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Patch_Level_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Patch_Level_Tx,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Version_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Version_Nm,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Version_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Version_Dt,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Version_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Version_Dsc,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Product_Version_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Product_Version_Ver_Num,
              NULL,
              'Product_Version_ID:'+cast(d.Product_Version_ID as varchar),
              row_number() over (order by d.Product_Version_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_PRODUCT_VERSION_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_PRODUCT_VERSION_AUDIT;
      PRINT 'VIEW dbo.vw_PRODUCT_VERSION_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_PRODUCT_VERSION_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Product_Version_ID) AS OLD_Product_Version_ID,
       MAX(TAB.NEW_Product_Version_ID) AS NEW_Product_Version_ID,
       MAX(TAB.OLD_Product_ID) AS OLD_Product_ID,
       MAX(TAB.NEW_Product_ID) AS NEW_Product_ID,
       MAX(TAB.OLD_Version_Tag_Tx) AS OLD_Version_Tag_Tx,
       MAX(TAB.NEW_Version_Tag_Tx) AS NEW_Version_Tag_Tx,
       MAX(TAB.OLD_Patch_Level_Tx) AS OLD_Patch_Level_Tx,
       MAX(TAB.NEW_Patch_Level_Tx) AS NEW_Patch_Level_Tx,
       MAX(TAB.OLD_Product_Version_Nm) AS OLD_Product_Version_Nm,
       MAX(TAB.NEW_Product_Version_Nm) AS NEW_Product_Version_Nm,
       MAX(TAB.OLD_Product_Version_Dt) AS OLD_Product_Version_Dt,
       MAX(TAB.NEW_Product_Version_Dt) AS NEW_Product_Version_Dt,
       MAX(TAB.OLD_Product_Version_Dsc) AS OLD_Product_Version_Dsc,
       MAX(TAB.NEW_Product_Version_Dsc) AS NEW_Product_Version_Dsc,
       MAX(TAB.OLD_Product_Version_Ver_Num) AS OLD_Product_Version_Ver_Num,
       MAX(TAB.NEW_Product_Version_Ver_Num) AS NEW_Product_Version_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_Version_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_Version_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.OLD_VALUE
                    END AS OLD_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_ID' THEN AT.NEW_VALUE
                    END AS NEW_Product_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Version_Tag_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Version_Tag_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Version_Tag_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Version_Tag_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Patch_Level_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Patch_Level_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Patch_Level_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Patch_Level_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Product_Version_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Product_Version_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Product_Version_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Product_Version_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Product_Version_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Product_Version_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Product_Version_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Product_Version_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Product_Version_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'PRODUCT_VERSION') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_RELATED_SERVER_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_RELATED_SERVER_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_RELATED_SERVER_AUDIT
ON dbo.RELATED_SERVER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Server_ID int;
   DECLARE @Related_Server_ID int;
   DECLARE @Server_Relationship_Cd int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'RELATED_SERVER';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar))+'|'+'Related_Server_ID:'+ISNULL(CAST(i.Related_Server_ID as varchar),CAST(d.Related_Server_ID as varchar))+'|'+'Server_Relationship_Cd:'+ISNULL(CAST(i.Server_Relationship_Cd as varchar),CAST(d.Server_Relationship_Cd as varchar)),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID and d.Related_Server_ID = i.Related_Server_ID and d.Server_Relationship_Cd = i.Server_Relationship_Cd
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Related_Server_ID,
                i.Related_Server_ID,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar))+'|'+'Related_Server_ID:'+ISNULL(CAST(i.Related_Server_ID as varchar),CAST(d.Related_Server_ID as varchar))+'|'+'Server_Relationship_Cd:'+ISNULL(CAST(i.Server_Relationship_Cd as varchar),CAST(d.Server_Relationship_Cd as varchar)),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID and d.Related_Server_ID = i.Related_Server_ID and d.Server_Relationship_Cd = i.Server_Relationship_Cd
         Where CASE
                  WHEN i.Related_Server_ID <> d.Related_Server_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Relationship_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Relationship_Cd,
                i.Server_Relationship_Cd,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar))+'|'+'Related_Server_ID:'+ISNULL(CAST(i.Related_Server_ID as varchar),CAST(d.Related_Server_ID as varchar))+'|'+'Server_Relationship_Cd:'+ISNULL(CAST(i.Server_Relationship_Cd as varchar),CAST(d.Server_Relationship_Cd as varchar)),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID and d.Related_Server_ID = i.Related_Server_ID and d.Server_Relationship_Cd = i.Server_Relationship_Cd
         Where CASE
                  WHEN i.Server_Relationship_Cd <> d.Server_Relationship_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Server_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Related_Server_Ver_Num,
                i.Related_Server_Ver_Num,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar))+'|'+'Related_Server_ID:'+ISNULL(CAST(i.Related_Server_ID as varchar),CAST(d.Related_Server_ID as varchar))+'|'+'Server_Relationship_Cd:'+ISNULL(CAST(i.Server_Relationship_Cd as varchar),CAST(d.Server_Relationship_Cd as varchar)),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID and d.Related_Server_ID = i.Related_Server_ID and d.Server_Relationship_Cd = i.Server_Relationship_Cd
         Where CASE
                  WHEN i.Related_Server_Ver_Num <> d.Related_Server_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Server_ID:'+cast(i.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(i.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(i.Server_Relationship_Cd as varchar),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Related_Server_ID,
                'Server_ID:'+cast(i.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(i.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(i.Server_Relationship_Cd as varchar),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Relationship_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Relationship_Cd,
                'Server_ID:'+cast(i.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(i.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(i.Server_Relationship_Cd as varchar),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Related_Server_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Related_Server_Ver_Num,
                'Server_ID:'+cast(i.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(i.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(i.Server_Relationship_Cd as varchar),
                row_number() over (order by i.Server_ID,i.Related_Server_ID,i.Server_Relationship_Cd)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(d.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(d.Server_Relationship_Cd as varchar),
              row_number() over (order by d.Server_ID,d.Related_Server_ID,d.Server_Relationship_Cd)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Related_Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Related_Server_ID,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(d.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(d.Server_Relationship_Cd as varchar),
              row_number() over (order by d.Server_ID,d.Related_Server_ID,d.Server_Relationship_Cd)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Relationship_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Relationship_Cd,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(d.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(d.Server_Relationship_Cd as varchar),
              row_number() over (order by d.Server_ID,d.Related_Server_ID,d.Server_Relationship_Cd)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Related_Server_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Related_Server_Ver_Num,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar)+'|'+'Related_Server_ID:'+cast(d.Related_Server_ID as varchar)+'|'+'Server_Relationship_Cd:'+cast(d.Server_Relationship_Cd as varchar),
              row_number() over (order by d.Server_ID,d.Related_Server_ID,d.Server_Relationship_Cd)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_RELATED_SERVER_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_RELATED_SERVER_AUDIT;
      PRINT 'VIEW dbo.vw_RELATED_SERVER_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_RELATED_SERVER_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Related_Server_ID) AS OLD_Related_Server_ID,
       MAX(TAB.NEW_Related_Server_ID) AS NEW_Related_Server_ID,
       MAX(TAB.OLD_Server_Relationship_Cd) AS OLD_Server_Relationship_Cd,
       MAX(TAB.NEW_Server_Relationship_Cd) AS NEW_Server_Relationship_Cd,
       MAX(TAB.OLD_Related_Server_Ver_Num) AS OLD_Related_Server_Ver_Num,
       MAX(TAB.NEW_Related_Server_Ver_Num) AS NEW_Related_Server_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Related_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Related_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Relationship_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Server_Relationship_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Relationship_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Server_Relationship_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Server_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Related_Server_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Related_Server_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Related_Server_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'RELATED_SERVER') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_SCHEDULE_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_SCHEDULE_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_SCHEDULE_AUDIT
ON dbo.SCHEDULE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Schedule_ID bigint;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'SCHEDULE';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_ID,
                i.Schedule_ID,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Schedule_ID <> d.Schedule_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_Nm,
                i.Schedule_Nm,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Schedule_Nm <> d.Schedule_Nm THEN 1
                  WHEN i.Schedule_Nm IS NULL AND d.Schedule_Nm IS NOT NULL THEN 1
                  WHEN i.Schedule_Nm IS NOT NULL AND d.Schedule_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_Dt,
                i.Schedule_Dt,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Schedule_Dt <> d.Schedule_Dt THEN 1
                  WHEN i.Schedule_Dt IS NULL AND d.Schedule_Dt IS NOT NULL THEN 1
                  WHEN i.Schedule_Dt IS NOT NULL AND d.Schedule_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Completion_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Completion_Dt,
                i.Completion_Dt,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Completion_Dt <> d.Completion_Dt THEN 1
                  WHEN i.Completion_Dt IS NULL AND d.Completion_Dt IS NOT NULL THEN 1
                  WHEN i.Completion_Dt IS NOT NULL AND d.Completion_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Request_Ticket_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Request_Ticket_Num,
                i.Request_Ticket_Num,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Request_Ticket_Num <> d.Request_Ticket_Num THEN 1
                  WHEN i.Request_Ticket_Num IS NULL AND d.Request_Ticket_Num IS NOT NULL THEN 1
                  WHEN i.Request_Ticket_Num IS NOT NULL AND d.Request_Ticket_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_Ver_Num,
                i.Schedule_Ver_Num,
                'Schedule_ID:'+ISNULL(CAST(i.Schedule_ID as varchar),CAST(d.Schedule_ID as varchar)),
                row_number() over (order by i.Schedule_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_ID = i.Schedule_ID
         Where CASE
                  WHEN i.Schedule_Ver_Num <> d.Schedule_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_ID,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_Nm,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_Dt,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Completion_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Completion_Dt,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Request_Ticket_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Request_Ticket_Num,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_Ver_Num,
                'Schedule_ID:'+cast(i.Schedule_ID as varchar),
                row_number() over (order by i.Schedule_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_ID,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_Nm,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_Dt,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Completion_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Completion_Dt,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Request_Ticket_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Request_Ticket_Num,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_Ver_Num,
              NULL,
              'Schedule_ID:'+cast(d.Schedule_ID as varchar),
              row_number() over (order by d.Schedule_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_SCHEDULE_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_SCHEDULE_AUDIT;
      PRINT 'VIEW dbo.vw_SCHEDULE_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_SCHEDULE_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Schedule_ID) AS OLD_Schedule_ID,
       MAX(TAB.NEW_Schedule_ID) AS NEW_Schedule_ID,
       MAX(TAB.OLD_Schedule_Nm) AS OLD_Schedule_Nm,
       MAX(TAB.NEW_Schedule_Nm) AS NEW_Schedule_Nm,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Schedule_Dt) AS OLD_Schedule_Dt,
       MAX(TAB.NEW_Schedule_Dt) AS NEW_Schedule_Dt,
       MAX(TAB.OLD_Completion_Dt) AS OLD_Completion_Dt,
       MAX(TAB.NEW_Completion_Dt) AS NEW_Completion_Dt,
       MAX(TAB.OLD_Request_Ticket_Num) AS OLD_Request_Ticket_Num,
       MAX(TAB.NEW_Request_Ticket_Num) AS NEW_Request_Ticket_Num,
       MAX(TAB.OLD_Schedule_Ver_Num) AS OLD_Schedule_Ver_Num,
       MAX(TAB.NEW_Schedule_Ver_Num) AS NEW_Schedule_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_ID' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_ID' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Completion_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Completion_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Completion_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Completion_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Request_Ticket_Num' THEN AT.OLD_VALUE
                    END AS OLD_Request_Ticket_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Request_Ticket_Num' THEN AT.NEW_VALUE
                    END AS NEW_Request_Ticket_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'SCHEDULE') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_SCHEDULE_DETAIL_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_SCHEDULE_DETAIL_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_SCHEDULE_DETAIL_AUDIT
ON dbo.SCHEDULE_DETAIL
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Schedule_Detail_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'SCHEDULE_DETAIL';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Detail_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_Detail_ID,
                i.Schedule_Detail_ID,
                'Schedule_Detail_ID:'+ISNULL(CAST(i.Schedule_Detail_ID as varchar),CAST(d.Schedule_Detail_ID as varchar)),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_Detail_ID = i.Schedule_Detail_ID
         Where CASE
                  WHEN i.Schedule_Detail_ID <> d.Schedule_Detail_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_ID,
                i.Schedule_ID,
                'Schedule_Detail_ID:'+ISNULL(CAST(i.Schedule_Detail_ID as varchar),CAST(d.Schedule_Detail_ID as varchar)),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_Detail_ID = i.Schedule_Detail_ID
         Where CASE
                  WHEN i.Schedule_ID <> d.Schedule_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_ID,
                i.Job_ID,
                'Schedule_Detail_ID:'+ISNULL(CAST(i.Schedule_Detail_ID as varchar),CAST(d.Schedule_Detail_ID as varchar)),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_Detail_ID = i.Schedule_Detail_ID
         Where CASE
                  WHEN i.Job_ID <> d.Job_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Order_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Order_Num,
                i.Order_Num,
                'Schedule_Detail_ID:'+ISNULL(CAST(i.Schedule_Detail_ID as varchar),CAST(d.Schedule_Detail_ID as varchar)),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_Detail_ID = i.Schedule_Detail_ID
         Where CASE
                  WHEN i.Order_Num <> d.Order_Num THEN 1
                  WHEN i.Order_Num IS NULL AND d.Order_Num IS NOT NULL THEN 1
                  WHEN i.Order_Num IS NOT NULL AND d.Order_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Detail_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Schedule_Detail_Ver_Num,
                i.Schedule_Detail_Ver_Num,
                'Schedule_Detail_ID:'+ISNULL(CAST(i.Schedule_Detail_ID as varchar),CAST(d.Schedule_Detail_ID as varchar)),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Schedule_Detail_ID = i.Schedule_Detail_ID
         Where CASE
                  WHEN i.Schedule_Detail_Ver_Num <> d.Schedule_Detail_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Detail_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_Detail_ID,
                'Schedule_Detail_ID:'+cast(i.Schedule_Detail_ID as varchar),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_ID,
                'Schedule_Detail_ID:'+cast(i.Schedule_Detail_ID as varchar),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_ID,
                'Schedule_Detail_ID:'+cast(i.Schedule_Detail_ID as varchar),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Order_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Order_Num,
                'Schedule_Detail_ID:'+cast(i.Schedule_Detail_ID as varchar),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Schedule_Detail_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Schedule_Detail_Ver_Num,
                'Schedule_Detail_ID:'+cast(i.Schedule_Detail_ID as varchar),
                row_number() over (order by i.Schedule_Detail_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_Detail_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_Detail_ID,
              NULL,
              'Schedule_Detail_ID:'+cast(d.Schedule_Detail_ID as varchar),
              row_number() over (order by d.Schedule_Detail_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_ID,
              NULL,
              'Schedule_Detail_ID:'+cast(d.Schedule_Detail_ID as varchar),
              row_number() over (order by d.Schedule_Detail_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_ID,
              NULL,
              'Schedule_Detail_ID:'+cast(d.Schedule_Detail_ID as varchar),
              row_number() over (order by d.Schedule_Detail_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Order_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Order_Num,
              NULL,
              'Schedule_Detail_ID:'+cast(d.Schedule_Detail_ID as varchar),
              row_number() over (order by d.Schedule_Detail_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Schedule_Detail_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Schedule_Detail_Ver_Num,
              NULL,
              'Schedule_Detail_ID:'+cast(d.Schedule_Detail_ID as varchar),
              row_number() over (order by d.Schedule_Detail_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_SCHEDULE_DETAIL_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_SCHEDULE_DETAIL_AUDIT;
      PRINT 'VIEW dbo.vw_SCHEDULE_DETAIL_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_SCHEDULE_DETAIL_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Schedule_Detail_ID) AS OLD_Schedule_Detail_ID,
       MAX(TAB.NEW_Schedule_Detail_ID) AS NEW_Schedule_Detail_ID,
       MAX(TAB.OLD_Schedule_ID) AS OLD_Schedule_ID,
       MAX(TAB.NEW_Schedule_ID) AS NEW_Schedule_ID,
       MAX(TAB.OLD_Job_ID) AS OLD_Job_ID,
       MAX(TAB.NEW_Job_ID) AS NEW_Job_ID,
       MAX(TAB.OLD_Order_Num) AS OLD_Order_Num,
       MAX(TAB.NEW_Order_Num) AS NEW_Order_Num,
       MAX(TAB.OLD_Schedule_Detail_Ver_Num) AS OLD_Schedule_Detail_Ver_Num,
       MAX(TAB.NEW_Schedule_Detail_Ver_Num) AS NEW_Schedule_Detail_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Detail_ID' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_Detail_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Detail_ID' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_Detail_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_ID' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_ID' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_ID' THEN AT.OLD_VALUE
                    END AS OLD_Job_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_ID' THEN AT.NEW_VALUE
                    END AS NEW_Job_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Order_Num' THEN AT.OLD_VALUE
                    END AS OLD_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Order_Num' THEN AT.NEW_VALUE
                    END AS NEW_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Detail_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Schedule_Detail_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Schedule_Detail_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Schedule_Detail_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'SCHEDULE_DETAIL') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_SERVER_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_SERVER_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_SERVER_AUDIT
ON dbo.SERVER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Server_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'SERVER';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Environment_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Environment_Type_Cd,
                i.Environment_Type_Cd,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Environment_Type_Cd <> d.Environment_Type_Cd THEN 1
                  WHEN i.Environment_Type_Cd IS NULL AND d.Environment_Type_Cd IS NOT NULL THEN 1
                  WHEN i.Environment_Type_Cd IS NOT NULL AND d.Environment_Type_Cd IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Nm,
                i.Server_Nm,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Server_Nm <> d.Server_Nm THEN 1
                  WHEN i.Server_Nm IS NULL AND d.Server_Nm IS NOT NULL THEN 1
                  WHEN i.Server_Nm IS NOT NULL AND d.Server_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Dsc,
                i.Server_Dsc,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Server_Dsc <> d.Server_Dsc THEN 1
                  WHEN i.Server_Dsc IS NULL AND d.Server_Dsc IS NOT NULL THEN 1
                  WHEN i.Server_Dsc IS NOT NULL AND d.Server_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Virtual_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Virtual_Fl,
                i.Virtual_Fl,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Virtual_Fl <> d.Virtual_Fl THEN 1
                  WHEN i.Virtual_Fl IS NULL AND d.Virtual_Fl IS NOT NULL THEN 1
                  WHEN i.Virtual_Fl IS NOT NULL AND d.Virtual_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Active_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Active_Fl,
                i.Server_Active_Fl,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Server_Active_Fl <> d.Server_Active_Fl THEN 1
                  WHEN i.Server_Active_Fl IS NULL AND d.Server_Active_Fl IS NOT NULL THEN 1
                  WHEN i.Server_Active_Fl IS NOT NULL AND d.Server_Active_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Abrx_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Abrx_Tx,
                i.Server_Abrx_Tx,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Server_Abrx_Tx <> d.Server_Abrx_Tx THEN 1
                  WHEN i.Server_Abrx_Tx IS NULL AND d.Server_Abrx_Tx IS NOT NULL THEN 1
                  WHEN i.Server_Abrx_Tx IS NOT NULL AND d.Server_Abrx_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_Ver_Num,
                i.Server_Ver_Num,
                'Server_ID:'+ISNULL(CAST(i.Server_ID as varchar),CAST(d.Server_ID as varchar)),
                row_number() over (order by i.Server_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Server_ID = i.Server_ID
         Where CASE
                  WHEN i.Server_Ver_Num <> d.Server_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Environment_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Environment_Type_Cd,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Nm,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Dsc,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Virtual_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Virtual_Fl,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Active_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Active_Fl,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Abrx_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Abrx_Tx,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_Ver_Num,
                'Server_ID:'+cast(i.Server_ID as varchar),
                row_number() over (order by i.Server_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Environment_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Environment_Type_Cd,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Nm,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Dsc,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Virtual_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Virtual_Fl,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Active_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Active_Fl,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Abrx_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Abrx_Tx,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_Ver_Num,
              NULL,
              'Server_ID:'+cast(d.Server_ID as varchar),
              row_number() over (order by d.Server_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_SERVER_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_SERVER_AUDIT;
      PRINT 'VIEW dbo.vw_SERVER_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_SERVER_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Environment_Type_Cd) AS OLD_Environment_Type_Cd,
       MAX(TAB.NEW_Environment_Type_Cd) AS NEW_Environment_Type_Cd,
       MAX(TAB.OLD_Server_Nm) AS OLD_Server_Nm,
       MAX(TAB.NEW_Server_Nm) AS NEW_Server_Nm,
       MAX(TAB.OLD_Server_Dsc) AS OLD_Server_Dsc,
       MAX(TAB.NEW_Server_Dsc) AS NEW_Server_Dsc,
       MAX(TAB.OLD_Virtual_Fl) AS OLD_Virtual_Fl,
       MAX(TAB.NEW_Virtual_Fl) AS NEW_Virtual_Fl,
       MAX(TAB.OLD_Server_Active_Fl) AS OLD_Server_Active_Fl,
       MAX(TAB.NEW_Server_Active_Fl) AS NEW_Server_Active_Fl,
       MAX(TAB.OLD_Server_Abrx_Tx) AS OLD_Server_Abrx_Tx,
       MAX(TAB.NEW_Server_Abrx_Tx) AS NEW_Server_Abrx_Tx,
       MAX(TAB.OLD_Server_Ver_Num) AS OLD_Server_Ver_Num,
       MAX(TAB.NEW_Server_Ver_Num) AS NEW_Server_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Environment_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Environment_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Environment_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Environment_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Server_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Server_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Server_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Server_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Virtual_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Virtual_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Virtual_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Virtual_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Active_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Server_Active_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Active_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Server_Active_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Abrx_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Server_Abrx_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Abrx_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Server_Abrx_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Server_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Server_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'SERVER') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_TASK_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_TASK_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_TASK_AUDIT
ON dbo.TASK
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Task_ID int;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'TASK';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_ID,
                i.Task_ID,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_ID <> d.Task_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Nm,
                i.Task_Nm,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Nm <> d.Task_Nm THEN 1
                  WHEN i.Task_Nm IS NULL AND d.Task_Nm IS NOT NULL THEN 1
                  WHEN i.Task_Nm IS NOT NULL AND d.Task_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Dsc',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Dsc,
                i.Task_Dsc,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Dsc <> d.Task_Dsc THEN 1
                  WHEN i.Task_Dsc IS NULL AND d.Task_Dsc IS NOT NULL THEN 1
                  WHEN i.Task_Dsc IS NOT NULL AND d.Task_Dsc IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Rollback_Task_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Rollback_Task_ID,
                i.Rollback_Task_ID,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Rollback_Task_ID <> d.Rollback_Task_ID THEN 1
                  WHEN i.Rollback_Task_ID IS NULL AND d.Rollback_Task_ID IS NOT NULL THEN 1
                  WHEN i.Rollback_Task_ID IS NOT NULL AND d.Rollback_Task_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Job_ID,
                i.Job_ID,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Job_ID <> d.Job_ID THEN 1
                  WHEN i.Job_ID IS NULL AND d.Job_ID IS NOT NULL THEN 1
                  WHEN i.Job_ID IS NOT NULL AND d.Job_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Type_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Type_Cd,
                i.Task_Type_Cd,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Type_Cd <> d.Task_Type_Cd THEN 1
                  WHEN i.Task_Type_Cd IS NULL AND d.Task_Type_Cd IS NOT NULL THEN 1
                  WHEN i.Task_Type_Cd IS NOT NULL AND d.Task_Type_Cd IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Order_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Order_Num,
                i.Order_Num,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Order_Num <> d.Order_Num THEN 1
                  WHEN i.Order_Num IS NULL AND d.Order_Num IS NOT NULL THEN 1
                  WHEN i.Order_Num IS NOT NULL AND d.Order_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Version_Specific_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Version_Specific_Fl,
                i.Version_Specific_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Version_Specific_Fl <> d.Version_Specific_Fl THEN 1
                  WHEN i.Version_Specific_Fl IS NULL AND d.Version_Specific_Fl IS NOT NULL THEN 1
                  WHEN i.Version_Specific_Fl IS NOT NULL AND d.Version_Specific_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Optional_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Optional_Fl,
                i.Optional_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Optional_Fl <> d.Optional_Fl THEN 1
                  WHEN i.Optional_Fl IS NULL AND d.Optional_Fl IS NOT NULL THEN 1
                  WHEN i.Optional_Fl IS NOT NULL AND d.Optional_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Continue_On_Error_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Continue_On_Error_Fl,
                i.Continue_On_Error_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Continue_On_Error_Fl <> d.Continue_On_Error_Fl THEN 1
                  WHEN i.Continue_On_Error_Fl IS NULL AND d.Continue_On_Error_Fl IS NOT NULL THEN 1
                  WHEN i.Continue_On_Error_Fl IS NOT NULL AND d.Continue_On_Error_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Request_Ticket_Required_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Request_Ticket_Required_Fl,
                i.Request_Ticket_Required_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Request_Ticket_Required_Fl <> d.Request_Ticket_Required_Fl THEN 1
                  WHEN i.Request_Ticket_Required_Fl IS NULL AND d.Request_Ticket_Required_Fl IS NOT NULL THEN 1
                  WHEN i.Request_Ticket_Required_Fl IS NOT NULL AND d.Request_Ticket_Required_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Send_Status_Email_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Send_Status_Email_Fl,
                i.Send_Status_Email_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Send_Status_Email_Fl <> d.Send_Status_Email_Fl THEN 1
                  WHEN i.Send_Status_Email_Fl IS NULL AND d.Send_Status_Email_Fl IS NOT NULL THEN 1
                  WHEN i.Send_Status_Email_Fl IS NOT NULL AND d.Send_Status_Email_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Do_Parameter_Substitution_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Do_Parameter_Substitution_Fl,
                i.Do_Parameter_Substitution_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Do_Parameter_Substitution_Fl <> d.Do_Parameter_Substitution_Fl THEN 1
                  WHEN i.Do_Parameter_Substitution_Fl IS NULL AND d.Do_Parameter_Substitution_Fl IS NOT NULL THEN 1
                  WHEN i.Do_Parameter_Substitution_Fl IS NOT NULL AND d.Do_Parameter_Substitution_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Manual_Fl',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Manual_Fl,
                i.Manual_Fl,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Manual_Fl <> d.Manual_Fl THEN 1
                  WHEN i.Manual_Fl IS NULL AND d.Manual_Fl IS NOT NULL THEN 1
                  WHEN i.Manual_Fl IS NOT NULL AND d.Manual_Fl IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Template_File_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Template_File_Nm,
                i.Task_Template_File_Nm,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Template_File_Nm <> d.Task_Template_File_Nm THEN 1
                  WHEN i.Task_Template_File_Nm IS NULL AND d.Task_Template_File_Nm IS NOT NULL THEN 1
                  WHEN i.Task_Template_File_Nm IS NOT NULL AND d.Task_Template_File_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Control_File_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Control_File_Nm,
                i.Task_Control_File_Nm,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Control_File_Nm <> d.Task_Control_File_Nm THEN 1
                  WHEN i.Task_Control_File_Nm IS NULL AND d.Task_Control_File_Nm IS NOT NULL THEN 1
                  WHEN i.Task_Control_File_Nm IS NOT NULL AND d.Task_Control_File_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Process_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Process_Nm,
                i.Task_Process_Nm,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Process_Nm <> d.Task_Process_Nm THEN 1
                  WHEN i.Task_Process_Nm IS NULL AND d.Task_Process_Nm IS NOT NULL THEN 1
                  WHEN i.Task_Process_Nm IS NOT NULL AND d.Task_Process_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_External_Ref_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_External_Ref_Tx,
                i.Task_External_Ref_Tx,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_External_Ref_Tx <> d.Task_External_Ref_Tx THEN 1
                  WHEN i.Task_External_Ref_Tx IS NULL AND d.Task_External_Ref_Tx IS NOT NULL THEN 1
                  WHEN i.Task_External_Ref_Tx IS NOT NULL AND d.Task_External_Ref_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Success_Return_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Success_Return_Num,
                i.Success_Return_Num,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Success_Return_Num <> d.Success_Return_Num THEN 1
                  WHEN i.Success_Return_Num IS NULL AND d.Success_Return_Num IS NOT NULL THEN 1
                  WHEN i.Success_Return_Num IS NOT NULL AND d.Success_Return_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Success_Return_Tx',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Success_Return_Tx,
                i.Success_Return_Tx,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Success_Return_Tx <> d.Success_Return_Tx THEN 1
                  WHEN i.Success_Return_Tx IS NULL AND d.Success_Return_Tx IS NOT NULL THEN 1
                  WHEN i.Success_Return_Tx IS NOT NULL AND d.Success_Return_Tx IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Contact_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Default_Contact_ID,
                i.Default_Contact_ID,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Default_Contact_ID <> d.Default_Contact_ID THEN 1
                  WHEN i.Default_Contact_ID IS NULL AND d.Default_Contact_ID IS NOT NULL THEN 1
                  WHEN i.Default_Contact_ID IS NOT NULL AND d.Default_Contact_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Ver_Num,
                i.Task_Ver_Num,
                'Task_ID:'+ISNULL(CAST(i.Task_ID as varchar),CAST(d.Task_ID as varchar)),
                row_number() over (order by i.Task_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_ID = i.Task_ID
         Where CASE
                  WHEN i.Task_Ver_Num <> d.Task_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_ID,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Nm,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Dsc',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Dsc,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Rollback_Task_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Rollback_Task_ID,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Job_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Job_ID,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Type_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Type_Cd,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Order_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Order_Num,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Version_Specific_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Version_Specific_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Optional_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Optional_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Continue_On_Error_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Continue_On_Error_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Request_Ticket_Required_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Request_Ticket_Required_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Send_Status_Email_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Send_Status_Email_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Do_Parameter_Substitution_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Do_Parameter_Substitution_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Manual_Fl',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Manual_Fl,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Template_File_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Template_File_Nm,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Control_File_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Control_File_Nm,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Process_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Process_Nm,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_External_Ref_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_External_Ref_Tx,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Success_Return_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Success_Return_Num,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Success_Return_Tx',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Success_Return_Tx,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Default_Contact_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Default_Contact_ID,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Ver_Num,
                'Task_ID:'+cast(i.Task_ID as varchar),
                row_number() over (order by i.Task_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_ID,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Nm,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Dsc',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Dsc,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Rollback_Task_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Rollback_Task_ID,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Job_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Job_ID,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Type_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Type_Cd,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Order_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Order_Num,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Version_Specific_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Version_Specific_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Optional_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Optional_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Continue_On_Error_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Continue_On_Error_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Request_Ticket_Required_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Request_Ticket_Required_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Send_Status_Email_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Send_Status_Email_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Do_Parameter_Substitution_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Do_Parameter_Substitution_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Manual_Fl',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Manual_Fl,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Template_File_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Template_File_Nm,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Control_File_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Control_File_Nm,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Process_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Process_Nm,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_External_Ref_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_External_Ref_Tx,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Success_Return_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Success_Return_Num,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Success_Return_Tx',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Success_Return_Tx,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Default_Contact_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Default_Contact_ID,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Ver_Num,
              NULL,
              'Task_ID:'+cast(d.Task_ID as varchar),
              row_number() over (order by d.Task_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_TASK_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_TASK_AUDIT;
      PRINT 'VIEW dbo.vw_TASK_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_TASK_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Task_ID) AS OLD_Task_ID,
       MAX(TAB.NEW_Task_ID) AS NEW_Task_ID,
       MAX(TAB.OLD_Task_Nm) AS OLD_Task_Nm,
       MAX(TAB.NEW_Task_Nm) AS NEW_Task_Nm,
       MAX(TAB.OLD_Task_Dsc) AS OLD_Task_Dsc,
       MAX(TAB.NEW_Task_Dsc) AS NEW_Task_Dsc,
       MAX(TAB.OLD_Rollback_Task_ID) AS OLD_Rollback_Task_ID,
       MAX(TAB.NEW_Rollback_Task_ID) AS NEW_Rollback_Task_ID,
       MAX(TAB.OLD_Job_ID) AS OLD_Job_ID,
       MAX(TAB.NEW_Job_ID) AS NEW_Job_ID,
       MAX(TAB.OLD_Task_Type_Cd) AS OLD_Task_Type_Cd,
       MAX(TAB.NEW_Task_Type_Cd) AS NEW_Task_Type_Cd,
       MAX(TAB.OLD_Order_Num) AS OLD_Order_Num,
       MAX(TAB.NEW_Order_Num) AS NEW_Order_Num,
       MAX(TAB.OLD_Version_Specific_Fl) AS OLD_Version_Specific_Fl,
       MAX(TAB.NEW_Version_Specific_Fl) AS NEW_Version_Specific_Fl,
       MAX(TAB.OLD_Optional_Fl) AS OLD_Optional_Fl,
       MAX(TAB.NEW_Optional_Fl) AS NEW_Optional_Fl,
       MAX(TAB.OLD_Continue_On_Error_Fl) AS OLD_Continue_On_Error_Fl,
       MAX(TAB.NEW_Continue_On_Error_Fl) AS NEW_Continue_On_Error_Fl,
       MAX(TAB.OLD_Request_Ticket_Required_Fl) AS OLD_Request_Ticket_Required_Fl,
       MAX(TAB.NEW_Request_Ticket_Required_Fl) AS NEW_Request_Ticket_Required_Fl,
       MAX(TAB.OLD_Send_Status_Email_Fl) AS OLD_Send_Status_Email_Fl,
       MAX(TAB.NEW_Send_Status_Email_Fl) AS NEW_Send_Status_Email_Fl,
       MAX(TAB.OLD_Do_Parameter_Substitution_Fl) AS OLD_Do_Parameter_Substitution_Fl,
       MAX(TAB.NEW_Do_Parameter_Substitution_Fl) AS NEW_Do_Parameter_Substitution_Fl,
       MAX(TAB.OLD_Manual_Fl) AS OLD_Manual_Fl,
       MAX(TAB.NEW_Manual_Fl) AS NEW_Manual_Fl,
       MAX(TAB.OLD_Task_Template_File_Nm) AS OLD_Task_Template_File_Nm,
       MAX(TAB.NEW_Task_Template_File_Nm) AS NEW_Task_Template_File_Nm,
       MAX(TAB.OLD_Task_Control_File_Nm) AS OLD_Task_Control_File_Nm,
       MAX(TAB.NEW_Task_Control_File_Nm) AS NEW_Task_Control_File_Nm,
       MAX(TAB.OLD_Task_Process_Nm) AS OLD_Task_Process_Nm,
       MAX(TAB.NEW_Task_Process_Nm) AS NEW_Task_Process_Nm,
       MAX(TAB.OLD_Task_External_Ref_Tx) AS OLD_Task_External_Ref_Tx,
       MAX(TAB.NEW_Task_External_Ref_Tx) AS NEW_Task_External_Ref_Tx,
       MAX(TAB.OLD_Success_Return_Num) AS OLD_Success_Return_Num,
       MAX(TAB.NEW_Success_Return_Num) AS NEW_Success_Return_Num,
       MAX(TAB.OLD_Success_Return_Tx) AS OLD_Success_Return_Tx,
       MAX(TAB.NEW_Success_Return_Tx) AS NEW_Success_Return_Tx,
       MAX(TAB.OLD_Default_Contact_ID) AS OLD_Default_Contact_ID,
       MAX(TAB.NEW_Default_Contact_ID) AS NEW_Default_Contact_ID,
       MAX(TAB.OLD_Task_Ver_Num) AS OLD_Task_Ver_Num,
       MAX(TAB.NEW_Task_Ver_Num) AS NEW_Task_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_ID' THEN AT.OLD_VALUE
                    END AS OLD_Task_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_ID' THEN AT.NEW_VALUE
                    END AS NEW_Task_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Task_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Task_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Dsc' THEN AT.OLD_VALUE
                    END AS OLD_Task_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Dsc' THEN AT.NEW_VALUE
                    END AS NEW_Task_Dsc,
                    CASE AT.COLUMN_NAME
                       WHEN 'Rollback_Task_ID' THEN AT.OLD_VALUE
                    END AS OLD_Rollback_Task_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Rollback_Task_ID' THEN AT.NEW_VALUE
                    END AS NEW_Rollback_Task_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_ID' THEN AT.OLD_VALUE
                    END AS OLD_Job_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Job_ID' THEN AT.NEW_VALUE
                    END AS NEW_Job_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Type_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Task_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Type_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Task_Type_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Order_Num' THEN AT.OLD_VALUE
                    END AS OLD_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Order_Num' THEN AT.NEW_VALUE
                    END AS NEW_Order_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Version_Specific_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Version_Specific_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Version_Specific_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Version_Specific_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Optional_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Optional_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Optional_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Optional_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Continue_On_Error_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Continue_On_Error_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Continue_On_Error_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Continue_On_Error_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Request_Ticket_Required_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Request_Ticket_Required_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Request_Ticket_Required_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Request_Ticket_Required_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Send_Status_Email_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Send_Status_Email_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Send_Status_Email_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Send_Status_Email_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Do_Parameter_Substitution_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Do_Parameter_Substitution_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Do_Parameter_Substitution_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Do_Parameter_Substitution_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Manual_Fl' THEN AT.OLD_VALUE
                    END AS OLD_Manual_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Manual_Fl' THEN AT.NEW_VALUE
                    END AS NEW_Manual_Fl,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Template_File_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Task_Template_File_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Template_File_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Task_Template_File_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Control_File_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Task_Control_File_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Control_File_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Task_Control_File_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Process_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Task_Process_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Process_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Task_Process_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_External_Ref_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Task_External_Ref_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_External_Ref_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Task_External_Ref_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Success_Return_Num' THEN AT.OLD_VALUE
                    END AS OLD_Success_Return_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Success_Return_Num' THEN AT.NEW_VALUE
                    END AS NEW_Success_Return_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Success_Return_Tx' THEN AT.OLD_VALUE
                    END AS OLD_Success_Return_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Success_Return_Tx' THEN AT.NEW_VALUE
                    END AS NEW_Success_Return_Tx,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Contact_ID' THEN AT.OLD_VALUE
                    END AS OLD_Default_Contact_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Default_Contact_ID' THEN AT.NEW_VALUE
                    END AS NEW_Default_Contact_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Task_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Task_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'TASK') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

IF OBJECT_ID('dbo.trg_IUD_TASK_INSTANCE_AUDIT') IS NOT NULL
   DROP TRIGGER dbo.trg_IUD_TASK_INSTANCE_AUDIT
GO

CREATE TRIGGER dbo.trg_IUD_TASK_INSTANCE_AUDIT
ON dbo.TASK_INSTANCE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

-- Trigger generated Wed Jan 16 06:46:35 2013 by BuildAuditTriggersW process

   -- Local declarations
   DECLARE @l_TableName   VARCHAR(32);
   DECLARE @l_PKValue     VARCHAR(200);
   DECLARE @l_AuditType   VARCHAR(10);
   DECLARE @l_Tag         VARCHAR(20);
   DECLARE @l_Datetime    DATETIME;

   DECLARE @Task_Instance_ID bigint;

   -- The table name for the audit will always be the same for this table
   Set @l_TableName = 'TASK_INSTANCE';

   -- Get the structure version tag from the db_control table so we know
   -- under what structure version the audit took place
   Select @l_Tag = Structure_Version_Tag From dbo.DB_CONTROL;

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
         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Instance_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Instance_ID,
                i.Task_Instance_ID,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Task_Instance_ID <> d.Task_Instance_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Server_ID,
                i.Server_ID,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Server_ID <> d.Server_ID THEN 1
                  WHEN i.Server_ID IS NULL AND d.Server_ID IS NOT NULL THEN 1
                  WHEN i.Server_ID IS NOT NULL AND d.Server_ID IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Organization_ID,
                i.Organization_ID,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Organization_ID <> d.Organization_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Status_Cd',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Status_Cd,
                i.Task_Status_Cd,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Task_Status_Cd <> d.Task_Status_Cd THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Instance_File_Nm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Instance_File_Nm,
                i.Instance_File_Nm,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Instance_File_Nm <> d.Instance_File_Nm THEN 1
                  WHEN i.Instance_File_Nm IS NULL AND d.Instance_File_Nm IS NOT NULL THEN 1
                  WHEN i.Instance_File_Nm IS NOT NULL AND d.Instance_File_Nm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_ID',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_ID,
                i.Task_ID,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Task_ID <> d.Task_ID THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Request_Ticket_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Request_Ticket_Num,
                i.Request_Ticket_Num,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Request_Ticket_Num <> d.Request_Ticket_Num THEN 1
                  WHEN i.Request_Ticket_Num IS NULL AND d.Request_Ticket_Num IS NOT NULL THEN 1
                  WHEN i.Request_Ticket_Num IS NOT NULL AND d.Request_Ticket_Num IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Completion_Wait_Tm',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Completion_Wait_Tm,
                i.Completion_Wait_Tm,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Completion_Wait_Tm <> d.Completion_Wait_Tm THEN 1
                  WHEN i.Completion_Wait_Tm IS NULL AND d.Completion_Wait_Tm IS NOT NULL THEN 1
                  WHEN i.Completion_Wait_Tm IS NOT NULL AND d.Completion_Wait_Tm IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Scheduled_Completion_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Scheduled_Completion_Dt,
                i.Scheduled_Completion_Dt,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Scheduled_Completion_Dt <> d.Scheduled_Completion_Dt THEN 1
                  WHEN i.Scheduled_Completion_Dt IS NULL AND d.Scheduled_Completion_Dt IS NOT NULL THEN 1
                  WHEN i.Scheduled_Completion_Dt IS NOT NULL AND d.Scheduled_Completion_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Scheduled_Completion_Dt_1',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Scheduled_Completion_Dt_1,
                i.Scheduled_Completion_Dt_1,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Scheduled_Completion_Dt_1 <> d.Scheduled_Completion_Dt_1 THEN 1
                  WHEN i.Scheduled_Completion_Dt_1 IS NULL AND d.Scheduled_Completion_Dt_1 IS NOT NULL THEN 1
                  WHEN i.Scheduled_Completion_Dt_1 IS NOT NULL AND d.Scheduled_Completion_Dt_1 IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Actual_Completion_Dt',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Actual_Completion_Dt,
                i.Actual_Completion_Dt,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Actual_Completion_Dt <> d.Actual_Completion_Dt THEN 1
                  WHEN i.Actual_Completion_Dt IS NULL AND d.Actual_Completion_Dt IS NOT NULL THEN 1
                  WHEN i.Actual_Completion_Dt IS NOT NULL AND d.Actual_Completion_Dt IS NULL THEN 1
                  ELSE 0
               END = 1;

         INSERT INTO dbo.Audit_Trail (Structure_Version_Tag, Table_Name, Column_Name, Audit_Type, [User_ID], Audit_Timestamp, Old_Value, New_Value, Primary_Key_Value, Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Instance_Ver_Num',
                @l_AuditType,
                i.UPDATE_USER_ID,
                @l_Datetime,
                d.Task_Instance_Ver_Num,
                i.Task_Instance_Ver_Num,
                'Task_Instance_ID:'+ISNULL(CAST(i.Task_Instance_ID as varchar),CAST(d.Task_Instance_ID as varchar)),
                row_number() over (order by i.Task_Instance_ID)
         FROM INSERTED i FULL OUTER JOIN DELETED d ON d.Task_Instance_ID = i.Task_Instance_ID
         Where CASE
                  WHEN i.Task_Instance_Ver_Num <> d.Task_Instance_Ver_Num THEN 1
                  ELSE 0
               END = 1;

      END
      ELSE
      BEGIN
         -- Insert action
         -- Audit Type
         Set @l_AuditType = 'INSERT';

         -- If the column has been changed, audit it
         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Instance_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Instance_ID,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Server_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Server_ID,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Organization_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Organization_ID,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Status_Cd',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Status_Cd,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Instance_File_Nm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Instance_File_Nm,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_ID',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_ID,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Request_Ticket_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Request_Ticket_Num,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Completion_Wait_Tm',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Completion_Wait_Tm,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Scheduled_Completion_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Scheduled_Completion_Dt,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Scheduled_Completion_Dt_1',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Scheduled_Completion_Dt_1,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Actual_Completion_Dt',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Actual_Completion_Dt,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

         Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
         SELECT @l_Tag,
                @l_TableName,
                'Task_Instance_Ver_Num',
                @l_AuditType,
                i.CREATE_USER_ID,
                @l_Datetime,
                NULL,
                i.Task_Instance_Ver_Num,
                'Task_Instance_ID:'+cast(i.Task_Instance_ID as varchar),
                row_number() over (order by i.Task_Instance_ID)
         FROM inserted i;

      END
   END
   ELSE
   BEGIN
      -- Delete action
      Set @l_AuditType = 'DELETE';

      -- If the column has been changed, audit it
       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Instance_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Instance_ID,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Server_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Server_ID,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Organization_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Organization_ID,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Status_Cd',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Status_Cd,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Instance_File_Nm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Instance_File_Nm,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_ID',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_ID,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Request_Ticket_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Request_Ticket_Num,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Completion_Wait_Tm',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Completion_Wait_Tm,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Scheduled_Completion_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Scheduled_Completion_Dt,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Scheduled_Completion_Dt_1',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Scheduled_Completion_Dt_1,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Actual_Completion_Dt',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Actual_Completion_Dt,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

       Insert Into dbo.Audit_Trail(Structure_Version_Tag,Table_Name,Column_Name,Audit_Type,[User_ID],Audit_Timestamp,Old_Value,New_Value,Primary_Key_Value,Sequence_Num)
       SELECT @l_Tag,
              @l_TableName,
              'Task_Instance_Ver_Num',
              @l_AuditType,
              d.CREATE_USER_ID,
              @l_Datetime,
              d.Task_Instance_Ver_Num,
              NULL,
              'Task_Instance_ID:'+cast(d.Task_Instance_ID as varchar),
              row_number() over (order by d.Task_Instance_ID)
       FROM deleted d;

   END

END
GO

IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'dbo' and table_name = N'vw_TASK_INSTANCE_AUDIT')
   BEGIN
      DROP VIEW dbo.vw_TASK_INSTANCE_AUDIT;
      PRINT 'VIEW dbo.vw_TASK_INSTANCE_AUDIT has been dropped.';
   END;
GO

CREATE VIEW dbo.vw_TASK_INSTANCE_AUDIT AS
SELECT TAB.AUDIT_TYPE,
       TAB.AUDIT_TIMESTAMP,
       TAB.TABLE_NAME,
       TAB.PRIMARY_KEY_VALUE,
       TAB.USER_ID,
       MAX(TAB.OLD_Task_Instance_ID) AS OLD_Task_Instance_ID,
       MAX(TAB.NEW_Task_Instance_ID) AS NEW_Task_Instance_ID,
       MAX(TAB.OLD_Server_ID) AS OLD_Server_ID,
       MAX(TAB.NEW_Server_ID) AS NEW_Server_ID,
       MAX(TAB.OLD_Organization_ID) AS OLD_Organization_ID,
       MAX(TAB.NEW_Organization_ID) AS NEW_Organization_ID,
       MAX(TAB.OLD_Task_Status_Cd) AS OLD_Task_Status_Cd,
       MAX(TAB.NEW_Task_Status_Cd) AS NEW_Task_Status_Cd,
       MAX(TAB.OLD_Instance_File_Nm) AS OLD_Instance_File_Nm,
       MAX(TAB.NEW_Instance_File_Nm) AS NEW_Instance_File_Nm,
       MAX(TAB.OLD_Task_ID) AS OLD_Task_ID,
       MAX(TAB.NEW_Task_ID) AS NEW_Task_ID,
       MAX(TAB.OLD_Request_Ticket_Num) AS OLD_Request_Ticket_Num,
       MAX(TAB.NEW_Request_Ticket_Num) AS NEW_Request_Ticket_Num,
       MAX(TAB.OLD_Completion_Wait_Tm) AS OLD_Completion_Wait_Tm,
       MAX(TAB.NEW_Completion_Wait_Tm) AS NEW_Completion_Wait_Tm,
       MAX(TAB.OLD_Scheduled_Completion_Dt) AS OLD_Scheduled_Completion_Dt,
       MAX(TAB.NEW_Scheduled_Completion_Dt) AS NEW_Scheduled_Completion_Dt,
       MAX(TAB.OLD_Scheduled_Completion_Dt_1) AS OLD_Scheduled_Completion_Dt_1,
       MAX(TAB.NEW_Scheduled_Completion_Dt_1) AS NEW_Scheduled_Completion_Dt_1,
       MAX(TAB.OLD_Actual_Completion_Dt) AS OLD_Actual_Completion_Dt,
       MAX(TAB.NEW_Actual_Completion_Dt) AS NEW_Actual_Completion_Dt,
       MAX(TAB.OLD_Task_Instance_Ver_Num) AS OLD_Task_Instance_Ver_Num,
       MAX(TAB.NEW_Task_Instance_Ver_Num) AS NEW_Task_Instance_Ver_Num
       FROM (SELECT AT.AUDIT_TYPE,
                    AT.AUDIT_TIMESTAMP,
                    AT.TABLE_NAME,
                    AT.PRIMARY_KEY_VALUE,
                    AT.USER_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Instance_ID' THEN AT.OLD_VALUE
                    END AS OLD_Task_Instance_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Instance_ID' THEN AT.NEW_VALUE
                    END AS NEW_Task_Instance_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.OLD_VALUE
                    END AS OLD_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Server_ID' THEN AT.NEW_VALUE
                    END AS NEW_Server_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.OLD_VALUE
                    END AS OLD_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Organization_ID' THEN AT.NEW_VALUE
                    END AS NEW_Organization_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Status_Cd' THEN AT.OLD_VALUE
                    END AS OLD_Task_Status_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Status_Cd' THEN AT.NEW_VALUE
                    END AS NEW_Task_Status_Cd,
                    CASE AT.COLUMN_NAME
                       WHEN 'Instance_File_Nm' THEN AT.OLD_VALUE
                    END AS OLD_Instance_File_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Instance_File_Nm' THEN AT.NEW_VALUE
                    END AS NEW_Instance_File_Nm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_ID' THEN AT.OLD_VALUE
                    END AS OLD_Task_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_ID' THEN AT.NEW_VALUE
                    END AS NEW_Task_ID,
                    CASE AT.COLUMN_NAME
                       WHEN 'Request_Ticket_Num' THEN AT.OLD_VALUE
                    END AS OLD_Request_Ticket_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Request_Ticket_Num' THEN AT.NEW_VALUE
                    END AS NEW_Request_Ticket_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Completion_Wait_Tm' THEN AT.OLD_VALUE
                    END AS OLD_Completion_Wait_Tm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Completion_Wait_Tm' THEN AT.NEW_VALUE
                    END AS NEW_Completion_Wait_Tm,
                    CASE AT.COLUMN_NAME
                       WHEN 'Scheduled_Completion_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Scheduled_Completion_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Scheduled_Completion_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Scheduled_Completion_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Scheduled_Completion_Dt_1' THEN AT.OLD_VALUE
                    END AS OLD_Scheduled_Completion_Dt_1,
                    CASE AT.COLUMN_NAME
                       WHEN 'Scheduled_Completion_Dt_1' THEN AT.NEW_VALUE
                    END AS NEW_Scheduled_Completion_Dt_1,
                    CASE AT.COLUMN_NAME
                       WHEN 'Actual_Completion_Dt' THEN AT.OLD_VALUE
                    END AS OLD_Actual_Completion_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Actual_Completion_Dt' THEN AT.NEW_VALUE
                    END AS NEW_Actual_Completion_Dt,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Instance_Ver_Num' THEN AT.OLD_VALUE
                    END AS OLD_Task_Instance_Ver_Num,
                    CASE AT.COLUMN_NAME
                       WHEN 'Task_Instance_Ver_Num' THEN AT.NEW_VALUE
                    END AS NEW_Task_Instance_Ver_Num
             FROM dbo.AUDIT_TRAIL AT
             WHERE AT.TABLE_NAME = 'TASK_INSTANCE') TAB
       GROUP BY TAB.AUDIT_TYPE,
                TAB.AUDIT_TIMESTAMP,
                TAB.TABLE_NAME,
                TAB.PRIMARY_KEY_VALUE,
                TAB.USER_ID;
GO

