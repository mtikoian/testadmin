-- If the procedure does not exist, create it as a placeholder stub.
IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  specific_schema = N'BISSec' AND specific_name = N'ValidateAccountEntitlement')
  BEGIN
    PRINT 'Procedure BISSec.ValidateAccountEntitlement does not exist. Creating stub procedure, ' + CONVERT(VARCHAR(30), getdate(), 121);

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE BISSec.ValidateAccountEntitlement As Raiserror(''This is a stub routine and should not exist'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        PRINT 'ERROR: Unable to create stub procedure BISSec.ValidateAccountEntitlement!';
        RAISERROR ('ERROR: Unable to create stub procedure BISSec.ValidateAccountEntitlement!', 16, 1);
      END;
  END
ELSE
  BEGIN
    PRINT 'Procedure BISSec.ValidateAccountEntitlement exists, ' + CONVERT(VARCHAR(30), getdate(), 121);
  END;
go

-- Alter the procedures
Alter PROCEDURE BISSec.ValidateAccountEntitlement (
   @pi_SEIOrganizationID VARCHAR(20) = NULL,
   @pi_SecuredUserLoginID VARCHAR(100) = NULL,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : ValidateAccountEntitlement
   Project: BIS Account Restriction Facility (BARF)
   Author : POBrien 01/20/2012
   Description : Updates the temporary table #AccountListValidated Entitled_Flag for each
                 row in the temporary table based on the user's entitlement to the Account_ID
                 based on the Account restriction rules in the BIS Account Restriction Facility (BARF).

                 The criteria in the BARF is related specifically to a user and
                 may be any of the following criteria from the Account table

                    Account_ID
                    Control_ID
                    Administrator_Cd
                    Branch_Cd
                    Accountant_Cd
                    Senior_Administrator_Cd
                    Minor_Account_Tp
                    Investment_Officer_Cd

                 The rules within a criteria are "OR'd" 

                 and "AND'd" across criterias.

   Note:         The temporary table
                                 
                    CREATE TABLE #AccountListValidated
                      (
                         Account_ID VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED
                       , Entitled_Flag BIT NOT NULL DEFAULT (0)
                      )
                
                 must exist at a scope above this stored procedure. All accounts
                 to be validated must be inserted into this table. The stored procedure
                 will set the Entitled_Flag bit based on the users entitlement to it.
                 
                 All rows will have the Entitled_Flag set to zero (0) after parameter
                 validation.



   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_SEIOrganizationID                INPUT  SEI Organization ID
   @pi_SecuredUserLoginID               INPUT  User Login ID
   @po_Error_Reason_Cd                  OUTPUT Error reason code               

   --------------------------------------------------------------------------------
   Error Reason codes: 

    1  – The user login id parameter was NULL(@pi_SecuredUserLoginID).
    2  – The user login id was not found (@pi_SecuredUserLoginID).
    3  - There are no defined rules for the user (@pi_SecuredUserLoginID).
    6 - The temporary table #AccountListValidated does not exist.
    7 - The account list was not populated (@pi_AccountList).
   11 - The SEI Organization ID parameter was NULL(@pi_SEIOrganizationID).
   12 - The SEI Organization ID was not found(@pi_SEIOrganizationID).

   --------------------------------------------------------------------------------
   Return Value: 0
   Success : 0
   Failure : Non zero value is sql error number.

   Revisions :
   --------------------------------------------------------------------------------
   pobrien   09/17/2012     Tag 20120917.1 Tracker # 936 
                            
                            Review as a new procedure as most everything was cloned from GetEntitledAccounts.
                            
   ================================================================================

=end text

=cut
***/
        -- Declarations

        -- Flags for the user rules. These correspond to the Qualification_Column table data.
        --
        -- Set Do_x flag set to 1 if any of the Qualification_Column_ID rules exist for the user, 0 otherwise.
        -- Set DoAll_x flag set to 1 if the All_Access_Flag is set for the type of Qualification_Column_ID for the user, 0 otherwise.
        --
        --    Qualification_Column
        --    ID  Name
        --    --  -----------------------
        --    1   Account_ID
        --    2   Control_ID
        --    3	Administrator_Cd
        --    4	Branch_Cd
        --    5	Accountant_Cd
        --    6	Senior_Administrator_Cd
        --    7	Minor_Account_Tp
        --    8	Investment_Officer_Cd
        --
        DECLARE @Do_Account_ID int;
        DECLARE @Do_Control_ID int;
        DECLARE @Do_Administrator_Cd int;
        DECLARE @Do_Branch_Cd int;
        DECLARE @Do_Accountant_Cd int;
        DECLARE @Do_Senior_Administrator_Cd int;
        DECLARE @Do_Minor_Account_Tp int;
        DECLARE @Do_Investment_Officer_Cd int;
        DECLARE @DoAll_Account_ID int;
        DECLARE @DoAll_Control_ID int;
        DECLARE @DoAll_Administrator_Cd int;
        DECLARE @DoAll_Branch_Cd int;
        DECLARE @DoAll_Accountant_Cd int;
        DECLARE @DoAll_Senior_Administrator_Cd int;
        DECLARE @DoAll_Minor_Account_Tp int;
        DECLARE @DoAll_Investment_Officer_Cd int;

        -- The dynamic sql string to execute. Calculated as
        --
        -- Select a.Account_ID From dbo.Account Inner Join #Senior_Administrator_Cd_Values qid3 on a.Senior_Administrator_Cd = qid3.Senior_Administrator_Cd
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --                                     <<< Repeated longest inner join clause                                                                   >>>
        --
        -- is 793 characters
        DECLARE @sql nvarchar(1000);

        -- Sum of the Do_x variables.
        DECLARE @Matches int;

        -- Secured_User.Secured_User_ID identity value related to the @pi_SecuredUserLoginID parameter.
        DECLARE @SecuredUserID int;

        -- Return code value for the stored procedure
        DECLARE @ReturnCode INT;

        -- Secured_User.Organization_ID
        DECLARE @OrganizationID INT;

        -- Supervisor_ID from users' organization
        DECLARE @SupervisorID SMALLINT;

        -- Shared_Master_Flag from users' organization
        DECLARE @SharedMasterFlag BIT;

        -- Qualification_Column.Qualification_Column_ID values.
        DECLARE @QID_Account_ID SMALLINT;
        DECLARE @QID_Control_ID SMALLINT;
        DECLARE @QID_Administrator_Cd SMALLINT;
        DECLARE @QID_Branch_Cd SMALLINT;
        DECLARE @QID_Accountant_Cd SMALLINT;
        DECLARE @QID_Senior_Administrator_Cd SMALLINT;
        DECLARE @QID_Minor_Account_Tp SMALLINT;
        DECLARE @QID_Investment_Officer_Cd SMALLINT;

        DECLARE @Counter INT;

        -- Stops the message that shows the count of the number of rows affected by a
        -- Transact-SQL statement or stored procedure from being returned as part of the result set
        SET  NOCOUNT ON;

        -- Initialize Variables
        -- --------------------

        -- On failure of validation check, the error reason code for the failure.
        SET @po_Error_Reason_Cd = 0;

        -- Initialize return code.
        SET @ReturnCode = 0;

        -- Qualification_Column.Qualification_Column_ID values from the seed data.
        SET @QID_Account_ID = 1;
        SET @QID_Control_ID = 2;
        SET @QID_Administrator_Cd = 3;
        SET @QID_Branch_Cd = 4;
        SET @QID_Accountant_Cd = 5;
        SET @QID_Senior_Administrator_Cd = 6;
        SET @QID_Minor_Account_Tp = 7;
        SET @QID_Investment_Officer_Cd = 8;

        -- Temporary tables for rule criteria values. These will potentially
        -- be joined to the dbo.Account table to filter the accounts returned based on
        -- the rules.
        CREATE TABLE #Account_ID_Values(
           Account_ID   VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Control_ID_Values(
           Control_ID   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Administrator_Cd_Values(
           Administrator_Cd   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Branch_Cd_Values(
           Branch_Cd   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Accountant_Cd_Values(
           Accountant_Cd   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Senior_Administrator_Cd_Values(
           Senior_Administrator_Cd   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Minor_Account_Tp_Values(
           Minor_Account_Tp   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #Investment_Officer_Cd_Values(
           Investment_Officer_Cd   SMALLINT NOT NULL PRIMARY KEY CLUSTERED);

        CREATE TABLE #EntitledAccounts(
           Account_ID   VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED);

        BEGIN TRY
            -- Validate all the parameters.
            -- Set the @po_Error_Reason_Cd based on validation results.

            -- Make sure the SEI Organization ID was valued
            IF (@pi_SEIOrganizationID IS NULL)
            BEGIN
               -- Set the reason code parameter
               Set @po_Error_Reason_Cd = 11;
               -- Return
               RETURN @ReturnCode;
            END;

            -- Make sure we can find the Organization by the SEI Organization ID
            Select @OrganizationID = Organization_ID, @SupervisorID = Supervisor_ID, @SharedMasterFlag = Shared_Master_Flag
            From BISSec.ORGANIZATION
            Where SEI_Organization_ID = @pi_SEIOrganizationID;
            
            if (@OrganizationID IS NULL)
            begin
               -- Set the reason code parameter
               Set @po_Error_Reason_Cd = 12;
               -- Return
               return @ReturnCode;
            end;

            -- Make sure the secured user login id was valued
            IF (@pi_SecuredUserLoginID IS NULL)
            BEGIN
               -- Set the reason code parameter
               Set @po_Error_Reason_Cd = 1;
               -- Return
               RETURN @ReturnCode;
            END;

            -- Make sure we can find the secured user
            SELECT @SecuredUserID = SU.Secured_User_ID
            FROM BISSec.SECURED_USER SU
            WHERE SU.Secured_User_Login_ID = @pi_SecuredUserLoginID
            AND Organization_ID = @OrganizationID;

            IF (@SecuredUserID IS NULL)
            BEGIN
               -- Set the reason code parameter
               Set @po_Error_Reason_Cd = 2;
               -- Return
               RETURN @ReturnCode;
            END;

            -- Make sure the temporary table exists
            IF Object_ID('tempdb..#AccountListValidated') IS NULL
            Begin
               -- Set the reason code parameter
               Set @po_Error_Reason_Cd = 6;
               -- Return
               RETURN @ReturnCode;
            End;

            Select @Counter = Count(*)
            From #AccountListValidated;
            If (@Counter < 1)
            Begin
               -- Set the reason code parameter
               Set @po_Error_Reason_Cd = 7;
               -- Return
               RETURN @ReturnCode;
            End;

            -- Set the temporary table #AccountListValidated column Entitled_Flag to zero (0).
            Update #AccountListValidated
               Set Entitled_Flag = 0;

            -- Determine which user rules are setup for the user.
            SELECT
                 @Do_Account_ID = MAX(YY.Do_Account_ID),
                 @DoAll_Account_ID = MAX(YY.DoAll_Account_ID),
                 @Do_Control_ID = MAX(YY.Do_Control_ID),
                 @DoAll_Control_ID = MAX(YY.DoAll_Control_ID),
                 @Do_Administrator_Cd = MAX(YY.Do_Administrator_Cd),
                 @DoAll_Administrator_Cd = MAX(YY.DoAll_Administrator_Cd),
                 @Do_Branch_Cd = MAX(YY.Do_Branch_Cd),
                 @DoAll_Branch_Cd = MAX(YY.DoAll_Branch_Cd),
                 @Do_Accountant_Cd = MAX(YY.Do_Accountant_Cd),
                 @DoAll_Accountant_Cd = MAX(YY.DoAll_Accountant_Cd),
                 @Do_Senior_Administrator_Cd = MAX(YY.Do_Senior_Administrator_Cd),
                 @DoAll_Senior_Administrator_Cd = MAX(YY.DoAll_Senior_Administrator_Cd),
                 @Do_Minor_Account_Tp = MAX(YY.Do_Minor_Account_Tp),
                 @DoAll_Minor_Account_Tp = MAX(YY.DoAll_Minor_Account_Tp),
                 @Do_Investment_Officer_Cd = MAX(YY.Do_Investment_Officer_Cd),
                 @DoAll_Investment_Officer_Cd = MAX(YY.DoAll_Investment_Officer_Cd)
            FROM (SELECT
                   CASE WHEN XX.Qid = @QID_Account_ID THEN 1 ELSE 0 END Do_Account_ID,
                   CASE WHEN XX.Qid = @QID_Account_ID AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Account_ID,
                   CASE WHEN XX.Qid = @QID_Control_ID THEN 1 ELSE 0 END Do_Control_ID,
                   CASE WHEN XX.Qid = @QID_Control_ID AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Control_ID,
                   CASE WHEN XX.Qid = @QID_Administrator_Cd THEN 1 ELSE 0 END Do_Administrator_Cd,
                   CASE WHEN XX.Qid = @QID_Administrator_Cd AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Administrator_Cd,
                   CASE WHEN XX.Qid = @QID_Branch_Cd THEN 1 ELSE 0 END Do_Branch_Cd,
                   CASE WHEN XX.Qid = @QID_Branch_Cd AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Branch_Cd,
                   CASE WHEN XX.Qid = @QID_Accountant_Cd THEN 1 ELSE 0 END Do_Accountant_Cd,
                   CASE WHEN XX.Qid = @QID_Accountant_Cd AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Accountant_Cd,
                   CASE WHEN XX.Qid = @QID_Senior_Administrator_Cd THEN 1 ELSE 0 END Do_Senior_Administrator_Cd,
                   CASE WHEN XX.Qid = @QID_Senior_Administrator_Cd AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Senior_Administrator_Cd,
                   CASE WHEN XX.Qid = @QID_Minor_Account_Tp THEN 1 ELSE 0 END Do_Minor_Account_Tp,
                   CASE WHEN XX.Qid = @QID_Minor_Account_Tp AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Minor_Account_Tp,
                   CASE WHEN XX.Qid = @QID_Investment_Officer_Cd THEN 1 ELSE 0 END Do_Investment_Officer_Cd,
                   CASE WHEN XX.Qid = @QID_Investment_Officer_Cd AND XX.DoAll = 1 THEN 1 ELSE 0 END DoAll_Investment_Officer_Cd
               FROM (SELECT UR.Qualification_Column_ID AS Qid,
                            MAX(CASE WHEN UR.All_Access_Flag = 1 THEN 1 ELSE 0 END) AS DoAll
                     FROM BISSec.USER_RULE UR
                     WHERE UR.Secured_User_ID = @SecuredUserID
                     GROUP BY UR.Secured_User_ID, UR.Qualification_Column_ID) XX) YY;

            -- How many user rules do we need to match on?
            SET @Matches = @Do_Account_ID + @Do_Control_ID + @Do_Administrator_Cd + @Do_Branch_Cd + @Do_Accountant_Cd + @Do_Senior_Administrator_Cd + @Do_Minor_Account_Tp + @Do_Investment_Officer_Cd;

            -- If there were no user rules defined for the user, they do not get to see any accounts.
            IF (@Matches = 0 OR @Matches IS NULL)
            BEGIN
               SET @po_Error_Reason_Cd = 3;
               -- Return
               RETURN @ReturnCode;
            END;
            
            -- Initialize SQL variables 
            SET @sql = '';

            -- If the user has All of at least one rule meaning everything 
            IF (@DoAll_Account_ID = 1 or @DoAll_Control_ID = 1 or @DoAll_Administrator_Cd = 1 or @DoAll_Branch_Cd = 1 or @DoAll_Accountant_Cd = 1 or @DoAll_Senior_Administrator_Cd = 1 or @DoAll_Minor_Account_Tp = 1 or @DoAll_Investment_Officer_Cd = 1)
            BEGIN
               If (@SharedMasterFlag = 1)
               Begin
                  -- Get all accounts restricted by the Shared Master Control ids

                  Insert Into #Control_ID_Values (Control_ID)
                  Select Related_Control_ID
                  From dbo.BANK_UNIT_DETAIL
                  Where Control_ID = @SupervisorID;

                  -- The sql to execute
                  Set @sql = 'Select a.Account_ID From dbo.Account a Inner Join #Control_ID_Values qid2 On a.Control_ID = qid2.Control_ID'; 
               End
               Else
               Begin
                  -- Get all accounts
                  
                  -- The sql to execute
                  Set @sql = 'Select a.Account_ID From dbo.Account a';
               End;
            END
            Else
            Begin
               -- If the organization is a shared master, special handling of the control id rules.
               If (@SharedMasterFlag = 1)
               Begin
                  -- No Control_ID rules
                  If (@Do_Control_ID = 0)
                  Begin
                     -- Use the IDS related to the supervisor
                     Insert Into #Control_ID_Values (Control_ID)
                        Select Related_Control_ID
                        From BANK_UNIT_DETAIL
                        Where Control_ID = @SupervisorID;
   
                     -- Turn on the Control_ID rules so we restrict for the shared master
                     Set @Do_Control_ID = 1;
                  End
                  Else
                  Begin
                     -- Control_ID rules exist. Limit the Control_ID's to those related to the supervisor.
                     Insert Into #Control_ID_Values (Control_ID)
                        Select bud.Related_Control_ID
                        From BANK_UNIT_DETAIL bud
                        Inner Join BISSec.USER_RULE ur On bud.Related_Control_ID = ur.Compare_Value_Num
                        Where bud.Control_ID = @SupervisorID
                        And ur.Secured_User_ID = @SecuredUserID AND ur.Qualification_Column_ID = @QID_Control_ID;
                  End;
               End
               -- Non share master
               Else
               Begin
                  -- Control_ID Rules
                  If (@Do_Control_ID = 1)
                  Begin
                     Insert Into #Control_ID_Values (Control_ID)
                        Select ur.Compare_Value_Num
                        From BISSec.USER_RULE ur
                        Where ur.Secured_User_ID = @SecuredUserID AND ur.Qualification_Column_ID = @QID_Control_ID;
                  End;
               End;
            
               -- Construct the individual rules
            
               -- Account_ID rules
               If (@Do_Account_ID = 1)
               Begin
                  Insert Into #Account_ID_Values (Account_ID)
                     Select Compare_Value_Text
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Account_ID;
                     
                  Set @sql = @sql + ' Inner Join #Account_ID_Values qid1 on a.Account_ID = qid1.Account_ID';
               End;
               
               -- Control_ID rules
               If (@Do_Control_ID = 1)
               Begin
                  -- The control id rules are handled differently as they may be affected by the shared master scenario.
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Control_ID_Values qid2 On a.Control_ID = qid2.Control_ID';
               End;

               -- Administrator_Cd rules
               If (@Do_Administrator_Cd = 1)
               Begin
                  Insert Into #Administrator_Cd_Values (Administrator_Cd)
                     Select Compare_Value_Num
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Administrator_Cd;
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Administrator_Cd_Values qid3 On a.Administrator_Cd = qid3.Administrator_Cd';
               End;

               -- Branch_Cd rules
               If (@Do_Branch_Cd = 1)
               Begin
                  Insert Into #Branch_Cd_Values (Branch_Cd)
                     Select Compare_Value_Num
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Branch_Cd;
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Branch_Cd_Values qid4 On a.Branch_Cd = qid4.Branch_Cd';
               End;

               -- Accountant_Cd rules
               If (@Do_Accountant_Cd = 1)
               Begin
                  Insert Into #Accountant_Cd_Values (Accountant_Cd)
                     Select Compare_Value_Num
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Accountant_Cd;
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Accountant_Cd_Values qid5 On a.Accountant_Cd = qid5.Accountant_Cd';
               End;

               -- Senior_Administrator_Cd rules
               If (@Do_Senior_Administrator_Cd = 1)
               Begin
                  Insert Into #Senior_Administrator_Cd_Values (Senior_Administrator_Cd)
                     Select Compare_Value_Num
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Senior_Administrator_Cd;
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Senior_Administrator_Cd_Values qid6 On a.Senior_Administrator_Cd = qid6.Senior_Administrator_Cd';
               End;

               -- Minor_Account_Tp rules
               If (@Do_Minor_Account_Tp = 1)
               Begin
                  Insert Into #Minor_Account_Tp_Values (Minor_Account_Tp)
                     Select Compare_Value_Num
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Minor_Account_Tp;
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Minor_Account_Tp_Values qid7 On a.Minor_Account_Tp = qid7.Minor_Account_Tp';
               End;
                  
               -- Investment_Officer_Cd rules
               If (@Do_Investment_Officer_Cd = 1)
               Begin
                  Insert Into #Investment_Officer_Cd_Values (Investment_Officer_Cd)
                     Select Compare_Value_Num
                     From BISSec.USER_RULE
                     Where Secured_User_ID = @SecuredUserID
                     And   Qualification_Column_ID = @QID_Investment_Officer_Cd;
                  
                  -- Concatenate the rules
                  Set @sql = @sql + ' Inner Join #Investment_Officer_Cd_Values qid8 On a.Investment_Officer_Cd = qid8.Investment_Officer_Cd';
               End;

               -- Construct the final SQL to execute
               SET @sql = 'Select a.Account_ID From dbo.Account a ' + @sql;   
            End ;

--            Debugging
--
--            Select * from #Account_ID_Values;
--            Select * from #Control_ID_Values;
--            Select * from #Administrator_Cd_Values;
--            Select * from #Branch_Cd_Values;
--            Select * from #Accountant_Cd_Values;
--            Select * from #Senior_Administrator_Cd_Values;
--            Select * from #Minor_Account_Tp_Values;
--            Select * from #Investment_Officer_Cd_Values;
--            select @sql;

            -- Execute the SQL
            Insert InTo #EntitledAccounts
               EXECUTE sp_executesql @sql;
            
            -- Update the temp table Entitled_Flag for accounts to which the user is entitled.
            Update alv
               Set Entitled_Flag = 1
            From #AccountListValidated alv
            Inner Join #EntitledAccounts ea on alv.Account_ID = ea.Account_ID;

        END TRY
        BEGIN CATCH
            -- Capture the sql error number to return to the caller
            SET @ReturnCode = ERROR_NUMBER();

            -- Roll back any active or uncommittable transactions
            -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
            -- XACT_STATE = -1 The transaction is in an uncommittable state
            IF XACT_STATE () <> 0
                BEGIN
                    ROLLBACK TRANSACTION;
                END;
        END CATCH;

        RETURN @ReturnCode;
    END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'BISSec' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'ValidateAccountEntitlement')
  BEGIN
    PRINT '<<< Altered PROCEDURE BISSec.ValidateAccountEntitlement >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED Altering PROCEDURE BISSec.ValidateAccountEntitlement >>>';
  END;
GO