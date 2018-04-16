--   Project: BIS Account Restriction Facility (BARF)

-- Schema
IF EXISTS (SELECT 1 FROM sys.schemas WHERE  name = N'$(BIS_SECURITY_SCHEMA)')
BEGIN
   DROP SCHEMA $(BIS_SECURITY_SCHEMA);
   PRINT '<<< DROPPED SCHEMA $(BIS_SECURITY_SCHEMA) >>>';
END;
GO
