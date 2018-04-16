-- If the procedure does not exist, create it as a placeholder stub.
IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  specific_schema = N'aga' AND specific_name = N'ActGrpSearch')
  BEGIN
    PRINT 'Procedure aga.ActGrpSearch does not exist. Creating stub procedure, ' + CONVERT(VARCHAR(30), getdate(), 121);

    DECLARE @stmnt NVARCHAR(100);
    SET @stmnt = N'CREATE PROCEDURE aga.ActGrpSearch As Set NoCount On';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        PRINT 'ERROR: Unable to create stub procedure aga.ActGrpSearch!';
        RAISERROR ('ERROR: Unable to create stub procedure aga.ActGrpSearch!', 16, 1);
      END;
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.ActGrpSearch exists, ' + CONVERT(VARCHAR(30), getdate(), 121);
  END;
go

-- Create the procedure
Alter PROCEDURE aga.ActGrpSearch
  @iv_SEIOrganizationID   VARCHAR(20) = NULL, -- 20120926.1
  @iv_SecuredUserLoginID  VARCHAR(100) = NULL
 ,@iv_accountgroupname    VARCHAR(48) = NULL
 ,@iv_accountgroupid      VARCHAR(20) = NULL
 ,@iv_accountid           VARCHAR(20) = NULL
 ,@iv_interestedpartyid   VARCHAR(12) = NULL
 ,@iv_addressline1tx      VARCHAR(36) = NULL
 ,@iv_grouptypes          VARCHAR(100) = NULL
 ,@in_SendToNum           SMALLINT = NULL
 ,@in_StatusNum           SMALLINT = NULL
AS
  BEGIN
    /*
    =pod

    =begin text

    Project: TSU - Account Group Goals

    Name: AccountGroupSearch

    Author: Patrick W. O'Brien 12/08/2010

    Description: Searches for Account_Group rows that qualify by the search criteria.

    Parameters:

    @iv_SEIOrganizationID     Required: BIS Organization.SEI_Organization_ID

    @iv_SecuredUserLoginID    Required: BIS Secured_User.Secured_User_Login_ID

    @iv_AccountGroupName    Account_Group.Account_Group_Name
                            This parameter may be null and it defaults to null.
                            A Null value will be treated as "all" values.

    @iv_AccountGroupID      Account_Group.Account_Group_ID
                            This parameter may be null and it defaults to null.
                            A Null value will be treated as "all" values.

    @iv_AccountID           Group_Detail.Account_ID
                            This parameter may be null and it defaults to null.
                            A Null value will be treated as "all" values.

    @iv_Intersted_Party_ID  BIS Interested_Party.Interested_Party_ID
                            This parameter may be null and it defaults to null.
                            A Null value will be treated as "all" values.

    @iv_Address_Line_1_Tx   BIS Interested_Party.Address_Line_1_Tx
                            This parameter may be null and it defaults to null.
                            A Null value will be treated as "all" values.

    @iv_GroupTypes          Comma separated list of Group_Type.Group_Type_Cd.
                            This parameter may be null and it defaults to null.
                            A Null value will be treated as "all" values.

                            Values are validated to be numeric and the value
                            of an existing Group_Type.Group_Type_Cd. No duplicates
                            are allowed.

                            This parameter has been allocated at one hundread characters
                            based on requirements of a maximum of ten codes plus the
                            delimeters, times three for unanticipated growth.

    @in_SendToNum           This parameter indicates if we should restrict the result set
                            based on particular "Send_To" flags being set.
                            1 - Qualify by Send_To_Performance_Flg and Send_To_Reporting_Flg being True or False.
                            2 - Qualify by Send_To_Performance_Flg being True.
                            3 - Qualify by Send_To_Reporting_Flg being True.
                            4 - Qualify by Send_To_Performance_Flg and Send_To_Reporting_Flg being True
                            5 - Qualify by Send_To_Performance_Flg and Send_To_Reporting_Flg being False

                            An invalid value results in an @in_SendToNum value of 1.

    @in_StatusNum           This parameter indicates if we should restring the result set
                            based on the Group_Is_Active_Flg being set.
                            1 - Qualify by the Group_Is_Active_Flg being True.
                            2 - Qualify by the Group_Is_Active_Flg being False.
                            3 - Qualify by the Group_Is_Active_Flg being True or False.

                            An invalid value results in an @in_Status value of 1.

    Returns:

      Account_Group.Account_Group_Num
      Account_Group.Account_Group_Name
      Account_Group.Account_Group_ID
      Account_Group.Update_Dt
      Group_Type.Group_Type_Cd
      Group_Type.Group_Type_Name
      Account_Group.group_is_active_flg,
      Account_Group.send_to_reporting_flg,
      Account_Group.send_to_performance_flg,
      Account_Group.Account_Group_Ver_Num

    Updated:

    Revisions:
    --------------------------------------------------------------------------------
    INI Date            Description
    --------------------------------------------------------------------------------
    Kumar Yadav 06.02.2011
                        Tracker # 31 - New request to return group_is_active_flg,send_to_reporting_flg
                        and send_to_performance_flg for all the account group search.

    SRM 2011-08-17.1    Modified to use the aga schema for all aga objects. Changed
                        the BIS object references from synonyms to the dbo.<table>.
                        Changed the format somewhat.

    PWO 2012-02-08.1    Added logic to implement the Account Group Security.

    PWO 2012-03-19.1    Tracker 234 Added Account_Group_Ver_Num to result set.

    pobrien 20120901.1  Tracker # 330. Expand Account_Group.Account_Group_Name from varchar(40) to varchar(48).

    pobrien 20120926.1  Tracker # 305. Added SEIOrganizationID parameter to use in lookup of Secured_User and Organization.

    =end text

    =cut

    */
    DECLARE @sql_error   INTEGER;

    DECLARE @lv_grouptypes   VARCHAR(100)
    DECLARE @lv_code   VARCHAR(100)
    DECLARE @ln_pos   INT
    DECLARE @ln_len   INT
    DECLARE @ln_count   INT
    DECLARE @ln_minperfstaflg   INT
    DECLARE @ln_maxperfstaflg   INT
    DECLARE @po_Error_Reason_Cd INT;
    DECLARE @msg   VARCHAR(200);
    DECLARE @ReturnCode int;

    -- Stops the message that shows the count of the number of rows affected by a
    -- Transact-SQL statement or stored procedure from being returned as part of the result set
    SET  NOCOUNT ON;

    set @sql_error = 0; -- 20120926.1 add

    -- Create the table that will be populated by the BISSec.GetEntitledGroups.
    IF object_id('tempdb..#UserEntitledGroups') IS NOT NULL
     DROP TABLE #UserEntitledGroups;

    CREATE TABLE #UserEntitledGroups(
      Account_Group_Num    INT PRIMARY KEY NOT NULL
     ,Account_Group_Name   VARCHAR(48) NOT NULL
     ,Account_Group_ID     VARCHAR(20) NOT NULL)

    -- 20120926.1 Begin change
    -- Create temporary table to hold group type codes specified by the user
    IF object_id('tempdb..#UserEntitledIPs') IS NOT NULL
                DROP TABLE #UserEntitledIPs;

    CREATE TABLE #UserEntitledIPs (
      Interested_Party_ID varchar(12) PRIMARY KEY NOT NULL
    );
    -- 20120926.1 End change

    -- Create temporary table to hold group type codes specified by the user
    IF object_id('tempdb..#grouptypes') IS NOT NULL
                DROP TABLE #grouptypes;

    CREATE TABLE #grouptypes (group_type_cd SMALLINT NOT NULL);

    -- Create temporary tables so we can qualify by the group active flag
    IF object_id('tempdb..#StatusFlag') IS NOT NULL
                DROP TABLE #StatusFlag;

    CREATE TABLE #StatusFlag (Group_Is_Active_Flg BIT NOT NULL);

    -- Create temporary tables so we can qualify by the send to flags
    IF object_id('tempdb..#SendToPerf') IS NOT NULL
                DROP TABLE #SendToPerf;

    CREATE TABLE #SendToPerf (Send_To_Performance_Flg BIT NOT NULL);

    IF object_id('tempdb..#SendToRept') IS NOT NULL
                DROP TABLE #SendToRept;

    CREATE TABLE #SendToRept (Send_To_Reporting_Flg BIT NOT NULL);

    BEGIN TRY
      -- 20120926.1 Begin change
      -- New code
      -- Validate the SEI Organization ID
      IF (@iv_SEIOrganizationID IS NULL)
      BEGIN
        RAISERROR ('@iv_SEIOrganizationID may not be null.', 16, 1);
      END;
      -- 20120926.1 End change
    
      -- Validate the secured user login id
      IF (@iv_SecuredUserLoginID IS NULL)
        BEGIN
          RAISERROR ('@iv_SecuredUserLoginID may not be null.', 16, 1);
        END;

      -- Validate the account group name parameter
      IF (len(rtrim(@iv_accountgroupname)) < 1) OR
         (@iv_accountgroupname IS NULL)
        BEGIN
          SET @iv_accountgroupname = '%';
        END

      -- Validate the account group id parameter
      IF (len(rtrim(@iv_accountgroupid)) < 1) OR
         (@iv_accountgroupid IS NULL)
        BEGIN
          SET @iv_accountgroupid = '%';
        END

      -- Validate the account id parameter
      IF (len(rtrim(@iv_accountid)) < 1) OR
         (@iv_accountid IS NULL)
        BEGIN
          SET @iv_accountid = '%';
        END

      -- Validate the recipient last name parameter
      IF (len(rtrim(@iv_interestedpartyid)) < 1) OR
         (@iv_interestedpartyid IS NULL)
        BEGIN
          SET @iv_interestedpartyid = '%';
        END

      -- Validate the recipient last name parameter
      IF (len(rtrim(@iv_addressline1tx)) < 1) OR
         (@iv_addressline1tx IS NULL)
        BEGIN
          SET @iv_addressline1tx = '%';
        END

      IF (@in_SendToNum IS NULL)
        BEGIN
          SET @in_SendToNum = 1;
        END;

      IF (@in_SendToNum < 1 OR
          @in_SendToNum > 5)
        BEGIN
          SET @in_SendToNum = 1;
        END;

      IF (@in_StatusNum IS NULL)
        BEGIN
          SET @in_StatusNum = 1;
        END;

      IF (@in_StatusNum < 1 OR
          @in_StatusNum > 3)
        BEGIN
          SET @in_StatusNum = 1;
        END;


      -- If the user did not specify any group codes, then treat this as an
      -- all group codes condition.
      IF (@iv_grouptypes IS NULL) OR
         (len(rtrim(ltrim(@iv_grouptypes))) < 1)
        BEGIN
          INSERT INTO
            #grouptypes
            SELECT group_type_cd FROM group_type;
        END
      ELSE
        -- Multiple group types were specified
        BEGIN
          -- Remove leading and trailing spaces from what the user specified and store
          -- it into a local variable
          SET @lv_grouptypes = rtrim(ltrim(@iv_grouptypes))

          -- Loop through the group types specified parsing out each group type
          -- and adding it to the temp table
          WHILE (len(@lv_grouptypes) > 0)
          BEGIN
            -- See if we find a comma delimiter in the group types
            SET @ln_pos      = charindex(
                                 ','
                                ,@lv_grouptypes)

            -- If we do not, it's the last group type code
            IF (@ln_pos = 0)
              BEGIN
                SET @lv_code       = @lv_grouptypes
                SET @lv_code       = rtrim(ltrim(@lv_code))
                SET @lv_grouptypes = ''
              END
            -- Extract the group code
            ELSE
              BEGIN
                -- Extract the group code
                SET @lv_code            = left(
                                            @lv_grouptypes
                                           ,@ln_pos - 1)
                SET @lv_code            = rtrim(ltrim(@lv_code))
                -- Remove the group code from group types left to process
                SET @lv_grouptypes      = right(
                                            @lv_grouptypes
                                           ,len(@lv_grouptypes) - @ln_pos)
              END

            -- Validate the group code is numeric
            IF (isnumeric(@lv_code) = 1)
              BEGIN
                -- Validate the group type code exists
                SELECT
                @ln_count = count(*)
                FROM
                group_type
                WHERE
                group_type_cd = cast(@lv_code AS SMALLINT)

                IF (@ln_count = 1)
                  BEGIN
                    -- Insert it into the temp table
                    INSERT INTO
                      #grouptypes(group_type_cd)
                    VALUES
                      (cast(@lv_code AS SMALLINT))
                  END
                ELSE
                  BEGIN
                    RAISERROR ('Parameter @in_GroupTypes. A group type code was not valid ', 16, 1)
                  END
              END
            ELSE
              BEGIN
                RAISERROR ('Parameter @in_GroupTypes did not contain a numeric value ', 16, 1)
              END
          END
        END

      -- Populate the sendto temporary tables
      IF (@in_SendToNum = 1)
        BEGIN
          INSERT INTO
            #SendToPerf(Send_To_Performance_Flg)
          VALUES
            (0);

          INSERT INTO
            #SendToPerf(Send_To_Performance_Flg)
          VALUES
            (1);

          INSERT INTO
            #SendToRept(Send_To_Reporting_Flg)
          VALUES
            (0);

          INSERT INTO
            #SendToRept(Send_To_Reporting_Flg)
          VALUES
            (1);
        END
      ELSE
        IF (@in_SendToNum = 2)
          BEGIN
            INSERT INTO
              #SendToPerf(Send_To_Performance_Flg)
            VALUES
              (1);

            INSERT INTO
              #SendToRept(Send_To_Reporting_Flg)
            VALUES
              (0);

            INSERT INTO
              #SendToRept(Send_To_Reporting_Flg)
            VALUES
              (1);
          END
        ELSE
          IF (@in_SendToNum = 3)
            BEGIN
              INSERT INTO
                #SendToPerf(Send_To_Performance_Flg)
              VALUES
                (0);

              INSERT INTO
                #SendToPerf(Send_To_Performance_Flg)
              VALUES
                (1);

              INSERT INTO
                #SendToRept(Send_To_Reporting_Flg)
              VALUES
                (1);
            END;
          ELSE
            IF (@in_SendToNum = 4)
              BEGIN
                INSERT INTO
                  #SendToPerf(Send_To_Performance_Flg)
                VALUES
                  (1);

                INSERT INTO
                  #SendToRept(Send_To_Reporting_Flg)
                VALUES
                  (1);
              END;
            ELSE
              IF (@in_SendToNum = 5)
                BEGIN
                  INSERT INTO
                    #SendToPerf(Send_To_Performance_Flg)
                  VALUES
                    (0);

                  INSERT INTO
                    #SendToRept(Send_To_Reporting_Flg)
                  VALUES
                    (0);
                END;

      IF (@in_StatusNum = 1)
        BEGIN
          INSERT INTO
            #StatusFlag(Group_Is_Active_Flg)
          VALUES
            (1);
        END
      ELSE
        IF (@in_StatusNum = 2)
          BEGIN
            INSERT INTO
              #StatusFlag(Group_Is_Active_Flg)
            VALUES
              (0);
          END
        ELSE
          IF (@in_StatusNum = 3)
            BEGIN
              INSERT INTO
                #StatusFlag(Group_Is_Active_Flg)
              VALUES
                (1);

              INSERT INTO
                #StatusFlag(Group_Is_Active_Flg)
              VALUES
                (0);
            END;

       -- Populate the temporary table
       -- 20120926.1 Begin change
       -- Old code
       -- EXEC @ReturnCode = aga.GetEntitledGroups @iv_SecuredUserLoginID ,@po_Error_Reason_Cd = @po_Error_Reason_Cd;
       -- New code
       EXEC @ReturnCode = aga.GetEntitledGroups @iv_SEIOrganizationID, @iv_SecuredUserLoginID ,@po_Error_Reason_Cd = @po_Error_Reason_Cd out;
       -- 20120926.1 End change

       IF ((@ReturnCode <> 0) OR
           (@po_Error_Reason_Cd <> 0))
         BEGIN
           SET @msg      = 'Unable to get entitled groups. ReturnCode=' +
                           cast(@returncode AS VARCHAR(12)) +
                           ' ErrorReasonCode=' +
                           cast(@po_Error_Reason_Cd AS VARCHAR(6));
           RAISERROR (@msg, 16, 1);
         END;


      -- Search for the account groups
      IF (((@iv_addressline1tx <> '%') OR
           (@iv_interestedpartyid <> '%')) AND
          (@iv_accountid <> '%'))
        BEGIN
          -- 20120926.1 Begin change
          Insert Into #UserEntitledIPs(Interested_Party_ID)
            Exec @ReturnCode = BISSec.GetEntitledIPs @iv_SEIOrganizationID, @iv_SecuredUserLoginID, @po_Error_Reason_Cd = @po_Error_Reason_Cd out;
          IF ((@ReturnCode <> 0) OR
              (@po_Error_Reason_Cd <> 0))
            BEGIN
              SET @msg      = 'Unable to get entitled ips. ReturnCode=' +
                              cast(@returncode AS VARCHAR(12)) +
                              ' ErrorReasonCode=' +
                              cast(@po_Error_Reason_Cd AS VARCHAR(6));
              RAISERROR (@msg, 16, 1);
            END;
          -- 20120926.1 End change
        
          SELECT
            DISTINCT ag.account_group_num
                    ,ag.account_group_name
                    ,ag.account_group_id
                    ,ag.update_dt
                    ,gt.group_type_cd
                    ,gt.group_type_name
                    ,ag.group_is_active_flg
                    ,ag.send_to_reporting_flg
                    ,ag.send_to_performance_flg
                    ,ag.Account_Group_Ver_Num -- Tracker 234
          FROM
            aga.Account_Group ag
            INNER JOIN #UserEntitledGroups ueg
              ON ag.account_group_num = ueg.account_group_num
            INNER JOIN #SendToPerf perf
              ON ag.Send_To_Performance_Flg = perf.Send_To_Performance_Flg
            INNER JOIN #SendToRept rept
              ON ag.Send_To_Reporting_Flg = rept.Send_To_Reporting_Flg
            INNER JOIN #StatusFlag stat
              ON ag.Group_Is_Active_Flg = stat.Group_Is_Active_Flg
            INNER JOIN aga.Group_Type gt
              ON ag.group_type_cd = gt.group_type_cd
            INNER JOIN #grouptypes tgt
              ON tgt.group_type_cd = gt.group_type_cd
            INNER JOIN aga.Group_Detail gd
              ON gd.account_group_num = ag.account_group_num
            INNER JOIN group_recipient gr
              ON gr.account_group_num = ag.account_group_num
            INNER JOIN dbo.INTERESTED_PARTY oip
              ON gr.Interested_Party_ID = oip.Interested_Party_ID
            -- 20120926.1 Begin change
            INNER JOIN #UserEntitledIPs ueip
              ON gr.Interested_Party_ID = ueip.Interested_Party_ID
            -- 20120926.1 End change
          WHERE
            ag.account_group_name LIKE @iv_accountgroupname AND
            ag.account_group_id LIKE @iv_accountgroupid AND
            gd.account_id LIKE @iv_accountid AND
            oip.interested_party_id LIKE @iv_interestedpartyid AND
            oip.address_line_1_tx LIKE @iv_addressline1tx
          ORDER BY
            ag.account_group_name;
        END
      ELSE
        IF (((@iv_addressline1tx <> '%') OR
             (@iv_interestedpartyid <> '%')) AND
            (@iv_accountid = '%'))
          BEGIN
            -- 20120926.1 Begin change
            Insert Into #UserEntitledIPs(Interested_Party_ID)
              Exec @ReturnCode = BISSec.GetEntitledIPs @iv_SEIOrganizationID, @iv_SecuredUserLoginID, @po_Error_Reason_Cd = @po_Error_Reason_Cd out;
            IF ((@ReturnCode <> 0) OR
                (@po_Error_Reason_Cd <> 0))
              BEGIN
                SET @msg      = 'Unable to get entitled ips. ReturnCode=' +
                                cast(@returncode AS VARCHAR(12)) +
                                ' ErrorReasonCode=' +
                                cast(@po_Error_Reason_Cd AS VARCHAR(6));
                RAISERROR (@msg, 16, 1);
              END;
            -- 20120926.1 End change

            SELECT
              DISTINCT ag.account_group_num
                      ,ag.account_group_name
                      ,ag.account_group_id
                      ,ag.update_dt
                      ,gt.group_type_cd
                      ,gt.group_type_name
                      ,ag.group_is_active_flg
                      ,ag.send_to_reporting_flg
                      ,ag.send_to_performance_flg
                      ,ag.Account_Group_Ver_Num -- Tracker 234
            FROM
              aga.Account_Group ag
              INNER JOIN #UserEntitledGroups ueg
                ON ag.account_group_num = ueg.account_group_num
              INNER JOIN #SendToPerf perf
                ON ag.Send_To_Performance_Flg = perf.Send_To_Performance_Flg
              INNER JOIN #SendToRept rept
                ON ag.Send_To_Reporting_Flg = rept.Send_To_Reporting_Flg
              INNER JOIN #StatusFlag stat
                ON ag.Group_Is_Active_Flg = stat.Group_Is_Active_Flg
              INNER JOIN aga.Group_Type gt
                ON ag.group_type_cd = gt.group_type_cd
              INNER JOIN #grouptypes tgt
                ON tgt.group_type_cd = gt.group_type_cd
              INNER JOIN aga.Group_Recipient gr
                ON gr.account_group_num = ag.account_group_num
              INNER JOIN dbo.INTERESTED_PARTY oip
                ON gr.Interested_Party_ID = oip.Interested_Party_ID
              -- 20120926.1 Begin change
              INNER JOIN #UserEntitledIPs ueip
                ON gr.Interested_Party_ID = ueip.Interested_Party_ID
              -- 20120926.1 End change
            WHERE
              ag.account_group_name LIKE @iv_accountgroupname AND
              ag.account_group_id LIKE @iv_accountgroupid AND
              oip.interested_party_id LIKE @iv_interestedpartyid AND
              oip.address_line_1_tx LIKE @iv_addressline1tx
            ORDER BY
              ag.account_group_name;
          END
        ELSE
          IF (((@iv_addressline1tx = '%') AND
               (@iv_interestedpartyid = '%')) AND
              (@iv_accountid <> '%'))
            BEGIN
              SELECT
                DISTINCT ag.account_group_num
                        ,ag.account_group_name
                        ,ag.account_group_id
                        ,ag.update_dt
                        ,gt.group_type_cd
                        ,gt.group_type_name
                        ,ag.group_is_active_flg
                        ,ag.send_to_reporting_flg
                        ,ag.send_to_performance_flg
                        ,ag.Account_Group_Ver_Num -- Tracker 234
            FROM
                aga.Account_Group ag
                INNER JOIN #UserEntitledGroups ueg
                  ON ag.account_group_num = ueg.account_group_num
                INNER JOIN #SendToPerf perf
                  ON ag.Send_To_Performance_Flg = perf.Send_To_Performance_Flg
                INNER JOIN #SendToRept rept
                  ON ag.Send_To_Reporting_Flg = rept.Send_To_Reporting_Flg
                INNER JOIN #StatusFlag stat
                  ON ag.Group_Is_Active_Flg = stat.Group_Is_Active_Flg
                INNER JOIN aga.Group_Type gt
                  ON ag.group_type_cd = gt.group_type_cd
                INNER JOIN #grouptypes tgt
                  ON tgt.group_type_cd = gt.group_type_cd
                INNER JOIN aga.Group_Detail gd
                  ON gd.account_group_num = ag.account_group_num
              WHERE
                ag.account_group_name LIKE @iv_accountgroupname AND
                ag.account_group_id LIKE @iv_accountgroupid AND
                gd.account_id LIKE @iv_accountid
              ORDER BY
                ag.account_group_name;
            END
          ELSE
            IF (((@iv_addressline1tx = '%') AND
                 (@iv_interestedpartyid = '%')) AND
                (@iv_accountid = '%'))
              BEGIN
                SELECT
                  DISTINCT ag.account_group_num
                          ,ag.account_group_name
                          ,ag.account_group_id
                          ,ag.update_dt
                          ,gt.group_type_cd
                          ,gt.group_type_name
                          ,ag.group_type_cd
                          ,ag.Group_Is_Active_Flg
                          ,ag.Send_To_Performance_Flg
                          ,ag.Send_To_Reporting_Flg
                          ,ag.Account_Group_Ver_Num -- Tracker 234
              FROM
                  aga.Account_Group ag
                  INNER JOIN #UserEntitledGroups ueg
                    ON ag.account_group_num = ueg.account_group_num
                  INNER JOIN #SendToPerf perf
                    ON ag.Send_To_Performance_Flg =
                         perf.Send_To_Performance_Flg
                  INNER JOIN #SendToRept rept
                    ON ag.Send_To_Reporting_Flg = rept.Send_To_Reporting_Flg
                  INNER JOIN #StatusFlag stat
                    ON ag.Group_Is_Active_Flg = stat.Group_Is_Active_Flg
                  INNER JOIN aga.Group_Type gt
                    ON ag.group_type_cd = gt.group_type_cd
                  INNER JOIN #grouptypes tgt
                    ON tgt.group_type_cd = gt.group_type_cd
                WHERE
                  ag.account_group_name LIKE @iv_accountgroupname AND
                  ag.account_group_id LIKE @iv_accountgroupid
                ORDER BY
                  ag.account_group_name;
              END
            ELSE
              BEGIN
                RAISERROR ('Unable to determine query to execute', 16, 1)
              END;
    END TRY
    BEGIN CATCH
      DECLARE
        @errno      INT
     ,  @errmsg     NVARCHAR(4000) -- 20120926.1 expanded from 100 to nvarchar(4000) to match function result.
     ,  @errsev     INT
     ,  @errstate   INT;

      SELECT
      @errno    = error_number()
     ,@errmsg   = error_message()
     ,@errsev   = error_severity()
     ,@errstate = error_state();

      RAISERROR (@errmsg, @errsev, @errstate);
    END CATCH

    IF @errno <> 0
      RETURN @errno
    ELSE
      RETURN @sql_error
  END
go

-- Validate if procedure has been created.
IF EXISTS
     (SELECT
        1
      FROM
        information_schema.routines
      WHERE
        specific_schema = N'aga' AND
        specific_name = N'ActGrpSearch')
  BEGIN
    PRINT 'Procedure aga.ActGrpSearch has been created, ' +
          CONVERT(
            VARCHAR(30)
           ,getdate()
           ,121);
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.ActGrpSearch has NOT been created.';
  END;
go
