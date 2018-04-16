
CREATE TABLE [dbo].[DB_CONTROL_HISTORY]
(
   [DB_Control_History_Dt]    DATETIME NOT NULL DEFAULT (getdate ()),
   [Structure_Version_Tag]    VARCHAR (20) NULL,
   [Code_Version_Tag]         VARCHAR (20) NULL,
   [Test_Env_Flg]             BIT NOT NULL,
   [Delta_Comment_Tx]         VARCHAR (100) NULL,
   [Last_Change_Process_Dt]   DATETIME NULL,
   [DB_Control_Ver_Num]       SMALLINT NOT NULL
)
ON [PRIMARY];
GO

CREATE TABLE [dbo].[DB_CONTROL]
(
   [Structure_Version_Tag]    VARCHAR (20) NULL,
   [Code_Version_Tag]         VARCHAR (20) NULL,
   [Test_Env_Flg]             BIT NOT NULL DEFAULT ( (0)),
   [Delta_Comment_Tx]         VARCHAR (100) NULL,
   [Last_Change_Process_Dt]   DATETIME NULL,
   [DB_Control_Ver_Num]       SMALLINT NOT NULL DEFAULT ( (1))
)
ON [PRIMARY];
GO

CREATE TRIGGER [dbo].[DB_CONTROL_Historian]
   ON [dbo].[DB_CONTROL]
   FOR INSERT, UPDATE, DELETE
AS
IF (SELECT COUNT (*) FROM inserted) > 0
   BEGIN
      IF (SELECT COUNT (*) FROM deleted) > 0
         BEGIN
            -- update (both inserted and deleted)
            INSERT [dbo].DB_CONTROL_HISTORY (Structure_Version_Tag,
                                       Code_Version_Tag,
                                       Test_Env_Flg,
                                       Delta_Comment_Tx,
                                       Last_Change_Process_Dt,
                                       DB_Control_Ver_Num)
               SELECT Structure_Version_Tag,
                      Code_Version_Tag,
                      Test_Env_Flg,
                      Delta_Comment_Tx,
                      Last_Change_Process_Dt,
                      DB_Control_Ver_Num
                 FROM inserted
         END
      ELSE
         BEGIN
            -- insert (only inserted)
            INSERT [dbo].DB_CONTROL_HISTORY (Structure_Version_Tag,
                                       Code_Version_Tag,
                                       Test_Env_Flg,
                                       Delta_Comment_Tx,
                                       Last_Change_Process_Dt,
                                       DB_Control_Ver_Num)
               SELECT Structure_Version_Tag,
                      Code_Version_Tag,
                      Test_Env_Flg,
                      Delta_Comment_Tx,
                      Last_Change_Process_Dt,
                      DB_Control_Ver_Num
                 FROM inserted
         END
   END
ELSE
   BEGIN
      INSERT [dbo].DB_CONTROL_HISTORY (Structure_Version_Tag,
                                 Code_Version_Tag,
                                 Test_Env_Flg,
                                 Delta_Comment_Tx,
                                 Last_Change_Process_Dt,
                                 DB_Control_Ver_Num)
         SELECT Structure_Version_Tag,
                Code_Version_Tag,
                Test_Env_Flg,
                Delta_Comment_Tx,
                Last_Change_Process_Dt,
                DB_Control_Ver_Num
           FROM deleted
   END
GO

CREATE TABLE [dbo].[AUDIT_TRAIL]
(
   [Audit_Trail_ID]          NUMERIC (15, 0) IDENTITY (1, 1) NOT NULL,
   [Structure_Version_Tag]   VARCHAR (20) NULL,
   [Table_Name]              VARCHAR (32) NOT NULL,
   [Column_Name]             VARCHAR (32) NOT NULL,
   [Audit_Type]              VARCHAR (10) NOT NULL,
   [User_ID]                 VARCHAR (80) NULL,
   [Audit_Timestamp]         DATETIME NOT NULL DEFAULT (getdate ()),
   [Old_Value]               VARCHAR (1000) NULL,
   [New_Value]               VARCHAR (1000) NULL,
   [Primary_Key_Value]       VARCHAR (200) NOT NULL,
   [Sequence_Num]            NUMERIC (15, 0) NOT NULL,
   [Split_Num]               INT NOT NULL DEFAULT(1),
   CONSTRAINT [AUDIT_TRAIL_PK] PRIMARY KEY
      CLUSTERED
      ([Audit_Trail_ID] ASC)
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


CREATE UNIQUE NONCLUSTERED INDEX [AUDIT_TRAIL_IX01]
   ON [dbo].[AUDIT_TRAIL] ([Audit_Timestamp], [Audit_Trail_ID])
   WITH (PAD_INDEX = OFF,
         FILLFACTOR = 100,
         IGNORE_DUP_KEY = OFF,
         STATISTICS_NORECOMPUTE = OFF,
         ALLOW_ROW_LOCKS = ON,
         ALLOW_PAGE_LOCKS = ON)
   ON [PRIMARY];
GO

IF EXISTS
       (SELECT *
          FROM information_schema.routines
         WHERE specific_schema = N'dbo' AND specific_name = N'AuditEntry')
    BEGIN
     DROP PROCEDURE dbo.AuditEntry;
        PRINT 'PROCEDURE dbo.AuditEntry has been dropped.';
    END;
GO

CREATE PROCEDURE [dbo].AuditEntry (@i_StructureVersionTag    VARCHAR (20),
                             @i_TableName              VARCHAR (32),
                             @i_ColumnName             VARCHAR (32),
                             @i_Operation              VARCHAR (10),
                             @i_PKValue                VARCHAR (200),
                             @i_OldValue               VARCHAR (1000),
                             @i_NewValue               VARCHAR (1000),
                             @i_UserId                 VARCHAR (80),
                             @i_TimeStamp              DATETIME)
AS
   BEGIN
      -- Insert the audit trail row
      INSERT INTO [dbo].Audit_Trail (Structure_Version_Tag,
                               Table_Name,
                               Column_Name,
                               Audit_Type,
                               Primary_Key_Value,
                               Old_Value,
                               New_Value,
                               [User_Id],
                               Audit_Timestamp)
      VALUES (@i_StructureVersionTag,
              @i_TableName,
              @i_ColumnName,
              @i_Operation,
              @i_PKValue,
              @i_OldValue,
              @i_NewValue,
              @i_UserId,
              @i_TimeStamp)
   END
GO

IF EXISTS
       (SELECT *
          FROM information_schema.routines
         WHERE specific_schema = N'dbo' AND specific_name = N'PurgeAuditTrail')
    BEGIN
     DROP PROCEDURE dbo.PurgeAuditTrail;
        PRINT 'PROCEDURE dbo.PurgeAuditTrail has been dropped.';
    END;
GO

-- Create the procedure
CREATE PROCEDURE [dbo].PurgeAuditTrail (@pi_KeepMonthsNum INT = 0) AS
    /***

    ================================================================================

    Name : PurgeAuditTrail

    Author : Patrick W. O'Brien 12/10/2010

    Description : Generic procedure to purge rows from the Audit_Trail table older
                  than the number of months specified.

    ===============================================================================

    Parameters :

    Name            |I/O|     Description
    pi_KeepMonthsNum I        Number of months of audit trail detail. Based
                              on the current date - number of months specified.

    --------------------------------------------------------------------------------

    Returns :

    Name         Type (length)     Description
    ErrorNumber  int               Error code - 0 success otherwise failure.

    --------------------------------------------------------------------------------

    Return Value: Return code

    Success : 0

    Failure : @@ERROR

    Error number and Description

    Revisions :

    --------------------------------------------------------------------------------

    Ini| Date | Description

    --------------------------------------------------------------------------------

    ================================================================================

    ***/


    BEGIN
        -- Declarations
        DECLARE @ErrorNumber   INT;
        DECLARE @PurgeBeforeDateTime   DATETIME;
        DECLARE @TopCount   INT;
        DECLARE @Counter   INT;

        BEGIN TRY
            -- Turn off message about rows affected.
            SET  NOCOUNT ON;

            -- Initialize
            SET @ErrorNumber = 0;
            SET @PurgeBeforeDateTime = NULL;
            SET @TopCount = 1000;
            SET @Counter = 1;

            -- @pi_KeepMonthsNum must be greater than zero.
            IF (@pi_KeepMonthsNum IS NULL)
                BEGIN
                    RAISERROR ('Parameter @pi_KeepMonthsNum is null', 16, 1);
                END
            ELSE
                IF (@pi_KeepMonthsNum < 1)
                    BEGIN
                        RAISERROR ('Parameter @pi_KeepMonthsNum is less than 1', 16, 1);
                    END;

            -- Calculate todays date minus the months to keep
            SET @PurgeBeforeDateTime = dateadd (Month, -abs (@pi_KeepMonthsNum), getdate ())

            -- Loop while we are still deleting rows
            WHILE (@Counter > 0)
                BEGIN
                    -- Start a transaction
                    BEGIN TRAN DeleteAuditTrail;

                    -- Delete rows
                    DELETE TOP (@TopCount)
                      FROM [dbo].audit_trail
                     WHERE Audit_Timestamp < @PurgeBeforeDateTime;

                    -- Get the rowcount deleted
                    SET @Counter = @@ROWCOUNT;

                    -- See if we should commit or rollback
                    IF (@Counter > 0)
                        BEGIN
                            COMMIT TRAN DeleteAuditTrail;
                        END
                    ELSE
                        BEGIN
                            ROLLBACK TRAN DeleteAuditTrail;
                        END;
                END;
        END TRY
        BEGIN CATCH
            DECLARE @errno INT, @errmsg VARCHAR (100), @errsev INT, @errstate INT;

            SELECT @errno = error_number (),
                   @errmsg = error_message (),
                   @errsev = error_severity (),
                   @errstate = error_state ();

            -- Roll back any active or uncommittable transactions
            IF XACT_STATE () <> 0
                BEGIN
                    ROLLBACK TRAN DeleteAuditTrail;
                END

            -- Raise the error
            RAISERROR (@errmsg, @errsev, @errstate);
        END CATCH

        RETURN @ErrorNumber;
    END;
GO