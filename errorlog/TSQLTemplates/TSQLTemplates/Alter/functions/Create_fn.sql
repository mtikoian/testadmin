IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_All')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_All
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_All >>>'
  END
GO

CREATE FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_All()
  /***
  =pod

  =begin text

     ================================================================================
     Name : tvf_GetAccountID_All
     Project: BIS Account Restriction Facility (BARF)
     Author : Patrick W. O'Brien 12/06/2011
     Description :

         Table Value Function to return all the Account_ID's from the BIS
         dbo.ACCOUNT table.
         
         Called from BIS BARF GetEntitledAccounts.

     ===============================================================================
     Parameters :
     Name                                | I/O | Description


     --------------------------------------------------------------------------------
     Error Reason codes:

     --------------------------------------------------------------------------------
     Return Value: Table of Account_ID's

     Revisions :
     --------------------------------------------------------------------------------
     Ini    | Date          | Description
     --------------------------------------------------------------------------------
     
     ================================================================================

  =end text

  =cut
  ***/
  RETURNS TABLE
AS
  RETURN (SELECT
            a.Account_ID
          FROM
            dbo.Account a);
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_All')
  BEGIN
    PRINT '<<< CREATED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_All >>>'
  END
GO