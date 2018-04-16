-- If the procedure does not exist, create it as a placeholder stub.
IF NOT EXISTS
     (SELECT
        1
      FROM
        information_schema.routines
      WHERE
        specific_schema = N'aga' AND
        specific_name = N'GetGrpRcp')
  BEGIN
    PRINT 'Procedure aga.GetGrpRcp does not exist. Creating stub procedure, ' +
          CONVERT(
            VARCHAR(30)
           ,getdate()
           ,121);

    DECLARE @stmnt   NVARCHAR(100);
    SET @stmnt = N'CREATE PROCEDURE aga.GetGrpRcp As Set NoCount On';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        PRINT 'ERROR: Unable to create stub procedure aga.GetGrpRcp!';
        RAISERROR ('ERROR: Unable to create stub procedure aga.GetGrpRcp!', 16, 1);
      END;
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.GetGrpRcp exists, ' +
          CONVERT(
            VARCHAR(30)
           ,getdate()
           ,121);
  END;
go

-- Alter the procedure
ALTER PROCEDURE aga.GetGrpRcp
  @iv_SEIOrganizationID   VARCHAR(20) = NULL, -- 20120926.1
  @iv_SecuredUserLoginID  VARCHAR(100) = NULL, -- 20120926.1
  @in_accountgroupnum     INT
 ,@iv_interestedpartyid   VARCHAR(12) = NULL
AS
  BEGIN
    /*
    =pod

    =begin text

      Project: TSU - Account Group Goals

      Name: GetGrpRcp

      Author: Patrick W. O'Brien 11/29/2010

      Description: Retrieves a specific Group_Recipient row or all Group_Recipient
                   rows for the Account_Group_Num.

      Parameters:

       @in_AccountGroupNum           Group_Detail.Account_Group_Num
                                     This field may not be null.

       @iv_Interested_Party_ID       Group_Detail.Interested_Party_ID
                                     This field may be null.

      Returns:

        Resultset:

            Group_Recipient.Account_Group_Num
            Group_Recipient.Interested_Party_ID
            ODR_Interested_Party.Address_Line_1_Tx - May be null.
    Below fields were addded on 06.09.2011 by KY - requested by Ramesh Trk #
            ODR_Interested_Party.Address_Line_2_Tx
            ODR_Interested_Party.Address_Line_3_Tx
            ODR_Interested_Party.Address_Line_4_Tx
            ODR_Interested_Party.Address_Line_5_Tx
            Group_Recipient.Create_Dt
            Group_Recipient.Group_Recipient_Ver_Num

      Updated:
    Revisions:
    --------------------------------------------------------------------------------
    INI Date            Description
    --------------------------------------------------------------------------------
    SRM 2011-08-17.1    Modified to use the aga schema for all aga objects. Changed
                        the BIS object references from synonyms to the dbo.<table>.
                        Changed the format somewhat.

    PWO 2012-02-08.1    Tracker 231. Added group recipient version number to result set.

    pobrien 20120926.1  Tracker # 305. Added SEIOrganizationID parameter to use in lookup of Secured_User and Organization.
                                       Added logic to implement entitled interested parties.

    =end text

    =cut

    */
    DECLARE @sql_error   INTEGER;
    DECLARE @ln_group_detail_num   INT;
    DECLARE @ln_count   INT
    DECLARE @ReturnCode   INT; -- 20120926.1 add
    DECLARE @po_Error_Reason_Cd   INT; -- 20120926.1 add
    DECLARE @msg   VARCHAR(200); -- 20120926.1 add

    -- 20120926.1 Begin change
    CREATE TABLE #IPListValidated(
      Interested_Party_ID   VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED
     ,Entitled_Flag         BIT NOT NULL DEFAULT (0));

    set @sql_error = 0;
    -- 20120926.1 End change

    BEGIN TRY
      -- 20120926.1 Begin change
      -- New code

      IF (@iv_SEIOrganizationID IS NULL)
        BEGIN
          RAISERROR ('@iv_SEIOrganizationID may not be null.', 16, 1);
        END;

      -- Validate the secured user login id
      IF (@iv_SecuredUserLoginID IS NULL)
        BEGIN
          RAISERROR ('@iv_SecuredUserLoginID may not be null.', 16, 1);
        END;

      -- 20120926.1 End change
    
      -- Validate the Account_Group_Num was passed
      IF @in_accountgroupnum IS NULL
        BEGIN
          RAISERROR ('Parameter @in_AccountGroupNum is required', 16, 1);
        END;

      -- Make sure the Account_Group exists
      SELECT
      @ln_count = count(*)
      FROM
      aga.Account_Group
      WHERE
      Account_Group_Num = @in_accountgroupnum;

      IF @ln_count < 1
        BEGIN
          RAISERROR ('Account Group does not exist', 16, 1);
        END;

      -- 20120926.1 Begin change
      -- Populate the #IPListValidated for either the interested party id passed
      -- or all the valid interested parties.
      IF @iv_interestedpartyid IS NOT NULL
        BEGIN
          INSERT INTO
            #IPListValidated(
              Interested_Party_ID
             ,Entitled_Flag)
          VALUES
            (
              @iv_interestedpartyid
             ,0);

          EXEC @ReturnCode      = BISSec.ValidateIPEntitlement @iv_SEIOrganizationID
                                                              ,@iv_SecuredUserLoginID
                                                              ,@po_Error_Reason_Cd OUT;

          IF ((@ReturnCode <> 0) OR
              (@po_Error_Reason_Cd <> 0))
            BEGIN
              SET @msg      = 'Unable to get entitled ips. ReturnCode=' +
                              cast(@returncode AS VARCHAR(12)) +
                              ' ErrorReasonCode=' +
                              cast(@po_Error_Reason_Cd AS VARCHAR(6));
              RAISERROR (@msg, 16, 1);
            END;
        END
      ELSE
        BEGIN
          INSERT INTO
            #IPListValidated(
              Interested_Party_ID
            )
          EXEC
            @ReturnCode      = BISSec.GetEntitledIPs @iv_SEIOrganizationID
                                                    ,@iv_SecuredUserLoginID
                                                    ,@po_Error_Reason_Cd OUT;

          IF ((@ReturnCode <> 0) OR
              (@po_Error_Reason_Cd <> 0))
            BEGIN
              SET @msg      = 'Unable to get entitled ips. ReturnCode=' +
                              cast(@returncode AS VARCHAR(12)) +
                              ' ErrorReasonCode=' +
                              cast(@po_Error_Reason_Cd AS VARCHAR(6));
              RAISERROR (@msg, 16, 1);
            END;
        END;

      -- 20120926.1 Eng change



      -- Get the row
      IF @iv_interestedpartyid IS NOT NULL
        BEGIN
          SELECT
            gr.account_group_num
           ,gr.interested_party_id
           ,oip.address_line_1_tx
           ,oip.address_line_2_tx
           ,oip.address_line_3_tx
           ,oip.address_line_4_tx
           ,oip.address_line_5_tx
           ,gr.Create_Dt
           ,gr.Group_Recipient_Ver_Num
          FROM
            aga.Group_Recipient gr
            INNER JOIN #IPListValidated ipv ON gr.Interested_Party_ID = ipv.Interested_Party_ID -- 20120926.1 new
            LEFT OUTER JOIN dbo.INTERESTED_PARTY oip
              ON gr.Interested_Party_ID = oip.Interested_Party_ID
          WHERE
            gr.Account_Group_Num = @in_accountgroupnum AND
            -- gr.Interested_Party_ID = @iv_interestedpartyid; -- 20120926.1
            gr.Interested_Party_ID = @iv_interestedpartyid AND
            ipv.Entitled_Flag = 1;
        END
      ELSE
        BEGIN
          SELECT
            gr.account_group_num
           ,gr.interested_party_id
           ,oip.address_line_1_tx
           ,oip.address_line_2_tx
           ,oip.address_line_3_tx
           ,oip.address_line_4_tx
           ,oip.address_line_5_tx
           ,gr.Create_Dt
           ,gr.Group_Recipient_Ver_Num
          FROM
            aga.Group_Recipient gr
            INNER JOIN #IPListValidated ipv ON gr.Interested_Party_ID = ipv.Interested_Party_ID -- 20120926.1 new
            LEFT OUTER JOIN dbo.INTERESTED_PARTY oip
              ON gr.Interested_Party_ID = oip.Interested_Party_ID
          WHERE
            gr.Account_Group_Num = @in_accountgroupnum;
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
        *
      FROM
        information_schema.routines
      WHERE
        specific_schema = N'aga' AND
        specific_name = N'GetGrpRcp')
  BEGIN
    PRINT 'Procedure aga.GetGrpRcp has been created.'
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.GetGrpRcp has NOT been created.'
  END;
go

PRINT ''