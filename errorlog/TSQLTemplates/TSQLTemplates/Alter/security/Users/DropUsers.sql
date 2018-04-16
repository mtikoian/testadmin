--   Project: BIS Account Restriction Facility (BARF)

-- Drop the user
IF EXISTS
     (SELECT *
      FROM   sys.database_principals
      WHERE  name = N'$(BIS_Security_User)' AND type IN ('U', 'S', 'C', 'K'))
  BEGIN
        DROP USER $(BIS_Security_User);
    PRINT '<<< DROPPED USER $(BIS_Security_User) FROM DATABASE $(DATABASE) >>>'
  END;
GO
