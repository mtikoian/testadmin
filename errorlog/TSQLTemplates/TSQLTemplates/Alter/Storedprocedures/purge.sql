-- If the procedure does not exist, create it as a placeholder stub.
IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  specific_schema = N'aga' AND specific_name = N'AGARecon')
  BEGIN
    PRINT 'Procedure aga.AGARecon does not exist. Creating stub procedure, ' + CONVERT(VARCHAR(30), getdate(), 121);

    DECLARE @stmnt NVARCHAR(100);
    SET @stmnt = N'CREATE PROCEDURE aga.AGARecon As Set NoCount On';
    EXEC sp_executesql @stmnt;
    IF (@@ERROR <> 0)
      BEGIN
        PRINT 'ERROR: Unable to create stub procedure aga.AGARecon!';
        RAISERROR ('ERROR: Unable to create stub procedure aga.AGARecon!', 16, 1);
      END;
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.AGARecon exists, ' + CONVERT(VARCHAR(30), getdate(), 121);
  END;
go

-- Alter the procedure
Alter PROCEDURE aga.AGARecon
AS
  BEGIN
    /*
    =pod

    =begin text

      Project: TSU - Account Group Admin

      Procedure: AGARecon

      Author: Patrick W. O'Brien 12/06/2010

      Description:

            Reconcile the AGA data with the current state of the BIS data as referenced by the ODR_* synonyms.

            1.  Apply the account_id changes to the GROUP_DETAIL and ACCOUNT_RECIPIENT tables. See note.

            2.  Apply interested party id changes to the GROUP_RECIPIENT and ACCOUNT_RECIPIENT tables. See note.

            3.  Log as exceptions and delete Group_Recipient rows where the Interested_Party_ID does not have a corresponding
                entry in BIS.

            4.  Log as exceptions and delete Account_Recipient rows that do not have a corresponding entry in the BIS for
                either the Account_ID or Interested_Party_ID

            5.  Log as exceptions and delete Group_Detail rows where the account_id does not have a corresponding entry in BIS

            6.  Log as exceptions the group_detail rows where the account_group is performance station related
                and the account_id in the related group_detail is not performance station eligible
                or
                the group_detail rows where the account_group is reporting related
                and the account_id in the related group_detail is not enhanced client reporting.

            7.  Delete exceptions that are 30 days old or older (Based on BIS Batch_Dt).

            Note:

                For item 1 and 2, changes are considered Account_ID and Interested_Party_ID updates, not
                inserts or deletes.

      Parameters:

        None

      Returns:

        0 - success, otherwise failure.

      Updated:

        pobrien 20120926.1  Tracker # 305. 
        
            Modified the rules for the "Account is not IE eligible" to be
            
               If the group has Send_To_Reporting_Flg ON And Enhanced_Client_Reporting_Fl is OFF, log an exception
               to the expcetions table.

        07/16/2012

          Tag 20120716.1
          Tracker # 303

          Added logic to log an exception message to the Exceptions table for Group_Detail
          rows that are deleted when the corresponding BIS Account_ID does not exist.

          Added logic to log an exception message to the Exceptions table for Group_Recipient
          rows that are deleted when the corresponding BIS Interested_Party_ID does not exist.

          Added logic to log an exception message to the Exceptions table for Account_Recipient
          rows that are deleted when the corresponding BIS Interested_Party_ID does not exist.

          Modified logic that deleted Group_Detail rows where the corresponding BIS Account_ID
          was not ecr related to just log an exception to the Exceptions table.

          Added logic to delete rows in the exception table that are 30 days or older.

          Removed prior inline tags.

        05/04/2012

          Updated to uncomment the interested party logic that has been commented out since
          02/15/2011. Added update date, user id and ver_num updates when updating rows.
          Tracker # 292 tagged code changes with 20120504.1

        03/23/2011  V11.2

           Added the reconciliation of groups that are reporting related to accomodate the enhanced client
           reporting flag.

        02/15/2011

           Commented out Interested_Party change logic as the changes do not come down as an update in BIS.
           This is being researched further and will probably be corrected by using the change ledger information
           in whatever form it takes in BIS.

    Revisions:
    --------------------------------------------------------------------------------
    INI Date            Description
    --------------------------------------------------------------------------------
    SRM 2011-08-17.1    Modified to use the aga schema for all aga objects. Changed
                        the BIS object references from synonyms to the dbo.<table>.
                        Changed the format somewhat.

    LLR  2012.12.14     Exceptions table now has Organization_ID on it -- modified inserts
                        to insert value.

                        also modified from synonyms to base bis tables since in same db (e.g. aga.ODR_Interested_Party).
                        it was very inconsistent.
    =end text

    =cut


    */
    DECLARE @sql_error   INTEGER;
    DECLARE @LastChangeProcessDt   DATETIME;
    DECLARE @NewChangeProcessDt   DATETIME;
    DECLARE @DefaultInclusionDateTime   DATETIME;
    DECLARE @AccountIDChangeType   INTEGER;
    DECLARE @InterestedPartyIDChangeType   INTEGER;
    DECLARE @AccountNumberTypeNm   VARCHAR(36);
    DECLARE @TaxpayerIDTypeNm   VARCHAR(36);
    DECLARE @MAX_VERSION   INT;
    DECLARE @UpdateDt   DATETIME;
    DECLARE @PurgeDt   DATETIME; -- Tag 20120716.1

    SET @MAX_VERSION = 10000;
    SET @UpdateDt    = getdate();

    BEGIN TRY
      -- Turn off message counts from SQL statements.
      SET  NOCOUNT ON;

      SET @AccountNumberTypeNm           = 'Account Number';
      SET @TaxpayerIDTypeNm              = 'Taxpayer ID';

      -- Create temporary table to hold the account_id and interested_party_id changes from the
      -- BIS database.
      CREATE TABLE #actchg(
        Change_Dt   DATETIME NOT NULL
       ,Type_Cd     SMALLINT NOT NULL
       ,Old_ID      VARCHAR(12) NOT NULL
       ,New_ID      VARCHAR(12) NOT NULL);

      -- Temporary table to hold interested party ids in AGA that do not exist in BIS
      CREATE TABLE #IPDelete(
        Interested_Party_ID   VARCHAR(12) NOT NULL PRIMARY KEY);

      -- Temporary table to hold account ids in AGA that do not exist in BIS
      CREATE TABLE #AccountDelete (Account_ID VARCHAR(12) NOT NULL PRIMARY KEY);

      -- Delete rows in the Exception table that are 30 days or older.

      -- Get the current batch date.
      SELECT
      @PurgeDt                       = Max(Batch_Dt)
      FROM
      dbo.bank_unit_status;

      -- Calculate a date 30 days prior to the batch date.
      SET @PurgeDt                       = dateadd(
                                             dd
                                            ,-30
                                            ,@PurgeDt);

      -- Start the transaction
      BEGIN TRAN T1;

      -- Delete the old Exceptions rows.
      DELETE FROM
        aga.Exceptions
      WHERE
        Exception_Dt <= @PurgeDt;

      -- Commit the transaction
      COMMIT TRAN T1;

      -- Start the transaction
      BEGIN TRAN T1;

      -- Set up the default inclusion datetime for an initial state.
      SET @DefaultInclusionDateTime      = cast(
                                             '01/01/1970 00:00:00 AM' AS DATETIME);

      -- Get the identifier type for account numbers
      SELECT
      @AccountIDChangeType           = Identifier_Type_Cd
      FROM
      dbo.IDENTIFIER_TYPE
      WHERE
      Identifier_Type_Nm = @AccountNumberTypeNm;

      IF (@@rowcount <> 1)
        RAISERROR ('Unable to find Identifer_Type_Cd for Account Number', 16, 1);

      -- Get the identifier type for the taxpayer ids
      SELECT
      @InterestedPartyIDChangeType   = Identifier_Type_Cd
      FROM
      dbo.IDENTIFIER_TYPE
      WHERE
      Identifier_Type_Nm = @TaxpayerIDTypeNm;

      IF (@@rowcount <> 1)
        RAISERROR ('Unable to find Identifer_Type_Cd for Taxpayer ID', 16, 1);

      -- Get the last change process datetime that we process from a prior recon. Given that we can
      -- be in an initial state, the recon never having been run before, we need to default to a
      -- date which will cause inclusion of all the changes.
      SELECT
      @LastChangeProcessDt           = coalesce(
                                         Last_Change_Process_Dt
                                        ,@DefaultInclusionDateTime)
      FROM
      aga.DB_Control;

      -- Get all the changes that are more recent than the last change process date
      -- into the temporary table from the BIS Identifier_Change table.
      INSERT INTO
        #actchg
        SELECT
          ie.Change_Dt
         ,ie.Identifier_Type_Cd
         ,ie.Old_Identifier_Tx
         ,ie.New_Identifier_Tx
        FROM
          dbo.IDENTIFIER_CHANGE ie
        WHERE
          ie.Old_Identifier_Tx IS NOT NULL AND
          ie.New_Identifier_Tx IS NOT NULL AND
          ie.Change_Dt > @LastChangeProcessDt;

      -- Get the datetime that we will use to update the DB_CONTROL field Last_Change_Process_Dt
      -- once the reconciliation has been succesfully completed.
      SELECT
      @NewChangeProcessDt            = max(Change_Dt)
      FROM
      #actchg;

      -- 1. Apply the account_id changes to the Group_Detail rows.
      UPDATE
        gd
      SET
        Account_ID                = chg.New_ID
       ,Update_Dt                 = @UpdateDt
       ,Update_User_ID            = 'AGARecon'
       ,Group_Detail_Ver_Num      = CASE
                                      WHEN Group_Detail_Ver_Num > @MAX_VERSION
                                      THEN
                                        1
                                      ELSE
                                        Group_Detail_Ver_Num + 1
                                    END
      FROM
        #actchg chg
        INNER JOIN aga.Group_Detail gd ON gd.Account_ID = chg.Old_ID
      WHERE
        chg.Type_Cd = @AccountIDChangeType;

      -- Apply the account_id changes to the Account_Recipient rows.
      UPDATE
        aga.Account_Recipient
      SET
        Account_ID                     = chg.New_ID
       ,Update_Dt                      = @UpdateDt
       ,Update_User_ID                 = 'AGARecon'
       ,Account_Recipient_Ver_Num      = CASE
                                           WHEN Account_Recipient_Ver_Num >
                                                  @MAX_VERSION
                                           THEN
                                             1
                                           ELSE
                                             Account_Recipient_Ver_Num + 1
                                         END
      FROM
        #actchg chg
      WHERE
        aga.Account_Recipient.Account_ID = chg.Old_ID AND
        chg.Type_Cd = @AccountIDChangeType;

      -- 2. Apply the interested party id changes to the Group_Recipient rows.
      UPDATE
        GROUP_RECIPIENT
      SET
        Interested_Party_ID          = chg.New_ID
       ,Update_Dt                    = @UpdateDt
       ,Update_User_ID               = 'AGARecon'
       ,Group_Recipient_Ver_Num      = CASE
                                         WHEN Group_Recipient_Ver_Num >
                                                @MAX_VERSION
                                         THEN
                                           1
                                         ELSE
                                           Group_Recipient_Ver_Num + 1
                                       END
      FROM
        #actchg chg
      WHERE
        GROUP_RECIPIENT.Interested_Party_ID = chg.Old_ID AND
        chg.Type_Cd = @InterestedPartyIDChangeType;

      UPDATE
        ACCOUNT_RECIPIENT
      SET
        Interested_Party_ID            = chg.New_ID
       ,Update_Dt                      = @UpdateDt
       ,Update_User_ID                 = 'AGARecon'
       ,Account_Recipient_Ver_Num      = CASE
                                           WHEN Account_Recipient_Ver_Num >
                                                  @MAX_VERSION
                                           THEN
                                             1
                                           ELSE
                                             Account_Recipient_Ver_Num + 1
                                         END
      FROM
        #actchg chg
      WHERE
        ACCOUNT_RECIPIENT.Interested_Party_ID = chg.Old_ID AND
        chg.Type_Cd = @InterestedPartyIDChangeType;

      -- 3. Delete Group_Recipient rows where the Interested_Party_ID does not have a corresponding
      --    entry in BIS for the Interested_Party_ID.
      --
      -- Find the Group_Recipient rows that are related to Interested_Party rows that do not exist in BIS.
      WITH IPtoDelete(Interested_Party_ID)
           AS (SELECT Interested_Party_ID FROM aga.Group_Recipient
               EXCEPT
               SELECT Interested_Party_ID FROM dbo.Interested_Party)  --2012.12.14 change from synonym
      INSERT INTO
        #IPDelete(Interested_Party_ID)
        SELECT Interested_Party_ID FROM IPtoDelete;

      -- Log an exception to the Exceptions table for Group_Recipient rows where the Interested_Party_ID
      -- does not exist in BIS.
      INSERT INTO
        aga.Exceptions(
          Process_Nm
         ,Reason_Tx
         ,Account_Group_ID
         ,Account_ID
         ,Interested_Party_ID
         ,Organization_ID) --2012.12.14
       SELECT
          'AGARecon'
         ,'Interested party is not in BIS and has been removed from AGA as a Group Recipient'
         ,ag.Account_Group_ID
         ,NULL
         ,gr.Interested_Party_ID
         ,ag.Organization_ID --2012.12.14
        FROM
          aga.Group_Recipient gr
          INNER JOIN aga.Account_Group ag
            ON gr.Account_Group_Num = ag.Account_Group_Num
          INNER JOIN #IPDelete ip
            ON gr.Interested_Party_ID = ip.Interested_Party_ID;

      -- Delete the Group_Recipient rows where the Interested_Party_ID does not exist in BIS.
      DELETE FROM
        aga.Group_Recipient
      WHERE
        aga.Group_Recipient.Interested_Party_ID IN
          (SELECT Interested_Party_ID FROM #IPDelete);

      -- Empty the temporary table for reuse.
      DELETE FROM
        #IPDelete;

      -- 4a. Delete Account_Recipient rows where the Account_ID does not have a corresponding
      --     entry in the BIS for the Account_ID.
      -- Find the Account_Recipient rows where the Account_ID does not exist in BIS.
      WITH AccountDelete(Account_ID)
           AS (SELECT Account_ID FROM aga.Account_Recipient
               EXCEPT
               SELECT Account_ID FROM dbo.ACCOUNT)  --2012.12.14 change from synonym
      INSERT INTO
        #AccountDelete(Account_ID)
        SELECT Account_ID FROM AccountDelete;

      -- Log an exception to the Exceptions table for Account_Recipient rows where the Account_ID
      -- does not exist in BIS.
      INSERT INTO
        aga.Exceptions(
          Process_Nm
         ,Reason_Tx
         ,Account_Group_ID
         ,Account_ID
         ,Interested_Party_ID
         ,Organization_ID) --2012.12.14
        SELECT
          'AGARecon'
         ,'Account is not in BIS and has been removed from AGA as a Account Recipient'
         ,NULL
         ,ar.Account_ID
         ,ar.Interested_Party_ID
         ,ar.Organization_ID  --2012.12.14
        FROM
          aga.Account_Recipient ar
          INNER JOIN #AccountDelete ad ON ar.Account_ID = ad.Account_ID;

      -- Delete the Account_Recipient rows where the Account_ID does not exist in BIS.
      DELETE FROM
        aga.Account_Recipient
      WHERE
        aga.Account_Recipient.Account_ID IN
          (SELECT Account_ID FROM #AccountDelete);

      -- Empty the temporary table for reuse.
      DELETE FROM
        #AccountDelete;

      -- 4b. Delete Account_Recipient rows where the Interested_Party_ID does not have a corresponding
      --     entry in the BIS for the Interested_Party_ID
      -- Find the Account_Recipient rows that are related to Interested_Party rows that do not exist in BIS.
      WITH IPtoDelete(Interested_Party_ID)
           AS (SELECT Interested_Party_ID FROM aga.Account_Recipient
               EXCEPT
               SELECT Interested_Party_ID FROM dbo.Interested_Party) --2012.12.14 change from synonym
      INSERT INTO
        #IPDelete(Interested_Party_ID)
        SELECT Interested_Party_ID FROM IPtoDelete;

      -- Log an exception to the Exceptions table for Account_Recipient rows where the Interested_Party_ID
      -- does not exist in BIS.
      INSERT INTO
        aga.Exceptions(
          Process_Nm
         ,Reason_Tx
         ,Account_Group_ID
         ,Account_ID
         ,Interested_Party_ID
         ,Organization_ID) --2012.12.14
        SELECT
          'AGARecon'
         ,'Interested party is not in BIS and has been removed from AGA as a Account Recipient'
         ,NULL
         ,ar.Account_ID
         ,ar.Interested_Party_ID
         ,ar.Organization_ID --2012.12.14
        FROM
          aga.Account_Recipient ar
          INNER JOIN #IPDelete ip
            ON ar.Interested_Party_ID = ip.Interested_Party_ID;

      -- Delete the Account_Recipient rows where the Interested_Party_ID does not exist in BIS.
      DELETE FROM
        aga.Account_Recipient
      WHERE
        aga.Account_Recipient.Interested_Party_ID IN
          (SELECT Interested_Party_ID FROM #IPDelete);

      -- Empty the temporary table for reuse.
      DELETE FROM
        #IPDelete;

      -- 5. Delete group detail rows where the corresponding account no longer exists in BIS.
      -- Find the Group_Detail rows where the Account_ID does not exist in BIS.
      WITH AccountDelete(Account_ID)
           AS (SELECT Account_ID FROM aga.Group_Detail
               Where Account_ID is not null
               EXCEPT
               SELECT Account_ID FROM dbo.ACCOUNT)  --2012.12.14 change from synonym
      INSERT INTO
        #AccountDelete(Account_ID)
        SELECT Account_ID FROM AccountDelete;

      -- Log an exception to the Exceptions table for Group_Detail rows where the Account_ID
      -- does not exist in BIS.
      INSERT INTO
        aga.Exceptions(
          Process_Nm
         ,Reason_Tx
         ,Account_Group_ID
         ,Account_ID
         ,Interested_Party_ID
         ,Organization_ID) --2012.12.14
        SELECT
          'AGARecon'
         ,'Account is not in BIS and has been removed from AGA as a Group Detail'
         ,ag.Account_Group_ID
         ,gd.Account_ID
         ,NULL
         ,ag.Organization_ID --2012.12.14
        FROM
          aga.Group_Detail gd
          INNER JOIN aga.Account_Group ag
            ON gd.Account_Group_Num = ag.Account_Group_Num
          INNER JOIN #AccountDelete ad ON gd.Account_ID = ad.Account_ID;

      -- Delete the Group_Detail rows where the Account_ID does not exist in BIS.
      DELETE FROM
        aga.Group_Detail
      WHERE
        aga.Group_Detail.Account_ID IN (SELECT Account_ID FROM #AccountDelete);

      -- Empty the temporary table for reuse.
      DELETE FROM
        #AccountDelete;

      -- 6. Log an exception to the Exceptions table for Group_Detail rows that are not IE eligible.
-- Tracker 305 Begin change
-- Old code
--      WITH EligibilityProblems(Group_Detail_Num)
--           AS (SELECT
--                 DISTINCT gd.Group_Detail_Num
--               FROM
--                 aga.Group_Detail gd
--                 INNER JOIN aga.Account_Group ag
--                   ON gd.account_group_num = ag.account_group_num
--                 INNER JOIN dbo.ACCOUNT oa ON gd.account_id = oa.account_id
--               WHERE
--                 gd.ACCOUNT_ID IS NOT NULL AND
--                 gd.Account_Group_Num = ag.Account_Group_Num AND
--                 (ag.Send_To_Reporting_Flg = 1 AND
--                  ag.Send_To_Performance_Flg = 0 AND
--                  (oa.enhanced_client_reporting_fl = 0)) OR
--                 (ag.Send_To_Reporting_Flg = 0 AND
--                  ag.Send_To_Performance_Flg = 1 AND
--                  oa.perf_station_eligible_fl = 0) OR
--                 (ag.Send_To_Reporting_Flg = 1 AND
--                  ag.Send_To_Performance_Flg = 1 AND
--                  (oa.enhanced_client_reporting_fl = 0 AND
--                   oa.perf_station_eligible_fl = 0)))
--      INSERT INTO
--        aga.Exceptions(
--          Process_Nm
--         ,Reason_Tx
--         ,Account_Group_ID
--         ,Account_ID
--         ,Interested_Party_ID)
--        SELECT
--          'AGARecon'
--         ,'Account is not IE eligible'
--         ,ag.Account_Group_ID
--         ,gd.Account_ID
--         ,NULL
--        FROM
--          EligibilityProblems ep
--          INNER JOIN aga.Group_Detail gd
--            ON ep.Group_Detail_Num = gd.Group_Detail_Num
--          INNER JOIN aga.Account_Group ag
--            ON gd.Account_Group_Num = ag.Account_Group_Num;
-- New code
      WITH EligibilityProblems(Group_Detail_Num)
           AS (SELECT
                 DISTINCT gd.Group_Detail_Num
               FROM
                 aga.Group_Detail gd
                 INNER JOIN aga.Account_Group ag
                   ON gd.account_group_num = ag.account_group_num
                 INNER JOIN dbo.ACCOUNT oa ON gd.account_id = oa.account_id
               WHERE
                 gd.ACCOUNT_ID IS NOT NULL AND
                 gd.Account_Group_Num = ag.Account_Group_Num AND
                 ag.Send_To_Reporting_Flg = 1 AND
                 oa.enhanced_client_reporting_fl = 0)
      INSERT INTO
        aga.Exceptions(
          Process_Nm
         ,Reason_Tx
         ,Account_Group_ID
         ,Account_ID
         ,Interested_Party_ID
         ,Organization_ID) --2012.12.14
        SELECT
          'AGARecon'
         ,'Account is not IE eligible'
         ,ag.Account_Group_ID
         ,gd.Account_ID
         ,NULL
         ,ag.Organization_ID       --2012.12.14
        FROM
          EligibilityProblems ep
          INNER JOIN aga.Group_Detail gd
            ON ep.Group_Detail_Num = gd.Group_Detail_Num
          INNER JOIN aga.Account_Group ag
            ON gd.Account_Group_Num = ag.Account_Group_Num;
-- Tracker 305 End change

      -- Update the DB_CONTROL field Last_Change_Process_Dt.
      UPDATE
        aga.DB_Control
      SET
        Last_Change_Process_Dt = @NewChangeProcessDt;

      -- Commit the transaction
      COMMIT TRAN T1;

      -- Return success
      RETURN 0;
    END TRY
    BEGIN CATCH
      DECLARE
        @errno      INT
     ,  @errmsg     VARCHAR(100)
     ,  @errsev     INT
     ,  @errstate   INT;

      SELECT
      @errno    = error_number()
     ,@errmsg   = error_message()
     ,@errsev   = error_severity()
     ,@errstate = error_state();

      ROLLBACK TRAN T1;

      RAISERROR (@errmsg, @errsev, @errstate);
    END CATCH

    IF @errno <> 0
      RETURN @errno
    ELSE
      RETURN @sql_error
  END
go

-- Validate the procedure has been altered i.e. it exists.
IF EXISTS
     (SELECT
        1
      FROM
        information_schema.routines
      WHERE
        specific_schema = N'aga' AND
        specific_name = N'AGARecon')
  BEGIN
    PRINT 'PROCEDURE aga.AGARecon has been altered, ' +
          CONVERT(
            VARCHAR(30)
           ,getdate()
           ,121);
  END
ELSE
  BEGIN
    PRINT 'ERROR: PROCEDURE aga.AGARecon does not exist!';
    RAISERROR('ERROR: PROCEDURE aga.AGARecon does not exist!',16,1);
  END;
go


