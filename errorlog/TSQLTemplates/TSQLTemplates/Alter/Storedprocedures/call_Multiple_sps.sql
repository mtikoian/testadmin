-- If the procedure does not exist, create it as a placeholder stub.
IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  specific_schema = N'aga' AND specific_name = N'RecipientSearch')
  BEGIN
    PRINT 'Procedure aga.RecipientSearch does not exist. Creating stub procedure, ' + CONVERT(VARCHAR(30), getdate(), 121);

    DECLARE @stmnt NVARCHAR(100);
    SET @stmnt = N'CREATE PROCEDURE aga.RecipientSearch As Set NoCount On';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        PRINT 'ERROR: Unable to create stub procedure aga.RecipientSearch!';
        RAISERROR ('ERROR: Unable to create stub procedure aga.RecipientSearch!', 16, 1);
      END;
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.RecipientSearch exists, ' + CONVERT(VARCHAR(30), getdate(), 121);
  END;
go

-- Alter the procedure
Alter PROCEDURE aga.RecipientSearch
  @iv_SEIOrganizationID   VARCHAR(20) = NULL -- 20120926.1 add
 ,@iv_SecuredUserLoginID  VARCHAR(80) = NULL -- 20120926.1 reordered
 ,@iv_interestedpartyid   VARCHAR(12) = NULL
 ,@iv_addressline1tx      VARCHAR(36) = NULL
 
AS
  BEGIN
    /*
    =pod

    =begin text

      Project: TSU - Account Group Goals

      Name: RecipientSearch

      Author: Patrick W. O'Brien 12/01/2010

      Description:

        This procedure will return information for Group_Recipients and Account_Recipients
        in a unified result set.

      Parameters:

        @iv_SEIOrganizationID   BISSec.Organization.SEI_Organization_ID

        @iv_SecuredUserLoginID  BISSec.Secured_User.Secured_User_Login_ID
                                This parameter may not be null.

        @iv_interestedpartyid   varchar Interested_Party.Interested_Party_ID
                                This parameter may be null and it defaults to null.

                                When null, the value is set to a '%' to mean all.

        @iv_addressline1tx      varchar Interested_Party.Address_Line_1_Tx
                                This parameter may be null and it defaults to null.

                                When null, the value is set to a '%' to mean all.


      Returns:

        Recipient_Type                  int     1 - Group_Recipient, 2 - Account_Recipient
        Account_Group_Num               int
        Account_ID                      varchar(12)
        Account_Short_Nm                varchar(36)
        Interested_Party_ID             varchar(12)
        Address_Line_1_Tx               varchar(36)
        Create_Dt                       datetime
        Ver_Num                         smallint
            Recipient_Type = 1 then Group_Recipient_Ver_Num
            Recipient_Type = 2 then Account_Recipient_Ver_Num)

      Updated:

        6/10/2011 Patrick W. O'Brien Tracker# 123

            Return these additional fields when matching by account recipient.

            Administrator.Administrator_Nm,
            Accountant.Accountant_Nm,
            Investment_Officer.Investment_Officer_Nm

      Notes:
    Revisions:
    --------------------------------------------------------------------------------
    INI Date            Description
    --------------------------------------------------------------------------------
    SRM 2011-08-17.1    Modified to use the aga schema for all aga objects. Changed
                        the BIS object references from synonyms to the dbo.<table>.
                        Changed the format somewhat.

    PWO 2012-02-08.1    Added logic to implement the Account Group Security.

    PWO 2012-03-19.1    Tracker 234. Added return of version number.

    pobrien 20120901.1  Tracker # 330. Expand Account_Group.Account_Group_Name from varchar(40) to varchar(48).
                        Removed prior modification inline comments.

    pobrien 20120926.1  Tracker # 305. Added SEIOrganizationID parameter to use in lookup of Secured_User and Organization.

    =end text

    =cut

    */
    DECLARE @sql_error   INTEGER;
    DECLARE @ReturnCode INTEGER;
    DECLARE @po_Error_Reason_Cd INTEGER;
    DECLARE @msg varchar(200);


    -- Initialize
    set @sql_error = 0; -- 20120926.1 add

    -- Temporary table to populate with the results from GetEntitledAccounts.
    IF (Object_ID('tempdb..#AccountList') IS NOT NULL)
      Drop Table #AccountList;
      
    CREATE TABLE #AccountList(
      Account_ID   VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED);

   -- 20120926.1 Begin change
    -- Temporary table to populate with the results from GetEntitledIPs.
    IF (Object_ID('tempdb..#IPList') IS NOT NULL)
      Drop Table #IPList;
      
    CREATE TABLE #IPList(
      Interested_Party_ID   VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED);
   -- 20120926.1 End change

    -- Temporary table to populate with the results from GetEntitledGroups.
    IF (Object_ID('tempdb..#UserEntitledGroups') IS NOT NULL)
      Drop Table #UserEntitledGroups;
      
    CREATE TABLE #UserEntitledGroups(
      Account_Group_Num    INT PRIMARY KEY NOT NULL
     ,Account_Group_Name   VARCHAR(48) NOT NULL
     ,Account_Group_ID     VARCHAR(20) NOT NULL);

    BEGIN TRY
      -- If the interested party id is null, set it to a percent sign meaning
      -- all in the where clause
      IF (@iv_interestedpartyid IS NULL)
        BEGIN
          SET @iv_interestedpartyid = '%';
        END;

      -- If the address line 1 text is null, set it to a percent sign meaning
      -- all in the where clause
      IF (@iv_addressline1tx IS NULL)
        BEGIN
          SET @iv_addressline1tx = '%'
        END;

      -- 20120926.1 Begin change
      IF (@iv_SecuredUserLoginID IS NULL)
        BEGIN
          RAISERROR ('SecuredUserLoginID may not be null', 16, 1);
        END;

      IF (@iv_SEIOrganizationID IS NULL)
        BEGIN
          RAISERROR ('SEIOrganizationID may not be null', 16, 1);
        END;
      -- 20120926.1 End change

      -- Get the entitled accounts
      INSERT INTO
        #AccountList
      -- 20120926.1 Begin change
      -- Old code
      --EXEC @ReturnCode = BISSec.GetEntitledAccounts @iv_SecuredUserLoginID, @po_Error_Reason_Cd   = @po_Error_Reason_Cd;
      -- New code
      EXEC @ReturnCode = BISSec.GetEntitledAccounts @iv_SEIOrganizationID, @iv_SecuredUserLoginID, @po_Error_Reason_Cd out;
      -- 20120926.1 End change
      IF ((@ReturnCode <> 0) OR
          (@po_Error_Reason_Cd <> 0))
         BEGIN
           SET @msg      = 'Unable to get entitled accounts. ReturnCode=' +
                           cast(@returncode AS VARCHAR(12)) +
                           ' ErrorReasonCode=' +
                           cast(@po_Error_Reason_Cd AS VARCHAR(6));
           RAISERROR (@msg, 16, 1);
         END;

      -- 20120926.1 Begin change
      -- New code
      Insert into #IPList (Interested_Party_ID)
         Exec @ReturnCode = BISSec.GetEntitledIPs @iv_SEIOrganizationID, @iv_SecuredUserLoginID, @po_Error_Reason_Cd out;
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

      -- Get the entitled groups
      EXEC @ReturnCode = aga.GetEntitledGroups @iv_SEIOrganizationID, @iv_SecuredUserLoginID, @po_Error_Reason_Cd out; -- 20120926.1
      IF ((@ReturnCode <> 0) OR
          (@po_Error_Reason_Cd <> 0))
         BEGIN
           SET @msg      = 'Unable to get entitled groups. ReturnCode=' +
                           cast(@returncode AS VARCHAR(12)) +
                           ' ErrorReasonCode=' +
                           cast(@po_Error_Reason_Cd AS VARCHAR(6));
           RAISERROR (@msg, 16, 1);
         END;

-- Debug
--Select 'UserEntitledGroups' TableName, * from #UserEntitledGroups;
--Select 'AccountList' TableName, * from #AccountList;
--Select 'IPList' TableName, * from #IPList;

      -- Select the Group_Recipient information
      SELECT
        1 [recipient_type]
       ,gr.account_group_num
       ,NULL [Account_ID]
       ,NULL [Account_Short_Nm]
       ,NULL [Administrator_Nm]
       ,NULL [Accountant_Nm]
       ,NULL [Investment_Officer_Nm]
       ,gr.interested_party_id
       ,oip.address_line_1_tx
       ,gr.create_dt
       ,gr.Group_Recipient_Ver_Num [Ver_Num] -- Tracker 234
      FROM
        aga.Group_Recipient gr
        INNER JOIN #UserEntitledGroups ueg
          ON gr.Account_Group_Num = ueg.Account_Group_Num
        INNER JOIN #IPList ipl on ipl.Interested_Party_ID = gr.Interested_Party_ID -- 20120926.1 add
        INNER JOIN dbo.INTERESTED_PARTY oip
          ON gr.interested_party_id = oip.interested_party_id
      WHERE
        gr.interested_party_id LIKE @iv_interestedpartyid AND
        oip.address_line_1_tx LIKE @iv_addressline1tx
      UNION
      -- Select the Account_Recipient information
      SELECT
        2 [type]
       ,NULL [Account_Group_Num]
       ,ar.account_id
       ,oa.account_short_nm
       ,oadm.administrator_nm
       ,oact.accountant_nm
       ,oio.investment_officer_nm
       ,ar.interested_party_id
       ,oip.address_line_1_tx
       ,ar.create_dt
       ,ar.Account_Recipient_Ver_Num [Ver_Num]
      FROM
        aga.Account_Recipient ar
        INNER JOIN #AccountList al
          ON ar.Account_ID = al.Account_ID
        INNER JOIN #IPList ipl on ipl.Interested_Party_ID = ar.Interested_Party_ID -- 20120926.1 add
        INNER JOIN dbo.ACCOUNT oa
          ON ar.Account_ID = oa.Account_ID
        INNER JOIN dbo.ADMINISTRATOR oadm
          ON oa.Administrator_Cd = oadm.Administrator_Cd
        INNER JOIN dbo.ACCOUNTANT oact
          ON oa.Accountant_Cd = oact.Accountant_Cd
        INNER JOIN dbo.INVESTMENT_OFFICER oio
          ON oa.Investment_Officer_Cd = oio.Investment_Officer_Cd
        INNER JOIN dbo.interested_party oip
          ON ar.interested_party_id = oip.interested_party_id
      WHERE
        ar.interested_party_id LIKE @iv_interestedpartyid AND
        oip.address_line_1_tx LIKE @iv_addressline1tx;
    END TRY
    BEGIN CATCH
      DECLARE
        @errno      INT
     -- ,  @errmsg     VARCHAR(100) 20120926.1
     ,  @errmsg     NVARCHAR(4000) -- 20120926.1
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
        specific_name = N'RecipientSearch')
  BEGIN
    PRINT 'Procedure aga.RecipientSearch has been created.'
  END
ELSE
  BEGIN
    PRINT 'Procedure aga.RecipientSearch has NOT been created.'
  END;
go
