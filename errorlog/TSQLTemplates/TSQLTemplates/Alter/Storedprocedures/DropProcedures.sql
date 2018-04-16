-- ====================================================
-- Project: BIS Account Restriction Facility (BARF)
--
-- POBrien Tracker 936 Tag 20120917.1
--
--    Commented out drop of GetControlIDs. SP is not used.
--    Added Drop of new SP UserAccountAnalysis.
-- ====================================================

-- Drop the procedures

-- ===========================================
-- Audit Trail related triggers
-- ===========================================
IF OBJECT_ID('$(BIS_SECURITY_SCHEMA).trg_DB_CONTROL_Historian') IS NOT NULL
   DROP TRIGGER $(BIS_SECURITY_SCHEMA).trg_DB_CONTROL_Historian;
GO

-- ==================================================
-- BIS Account Restriction Facility Stored Procedures
-- ==================================================

-- 20120917.1 Begin change
-- Old Code
-- Procedure was unused and has been dropped.
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'GetControlIDs')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).GetControlIDs;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).GetControlIDs >>>';
  END;
GO
-- New code
IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'UserAccountAnalysis')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).UserAccountAnalysis;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).UserAccountAnalysis >>>';
  END;
GO
IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'UserIPAnalysis')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).UserIPAnalysis;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).UserIPAnalysis >>>';
  END;
GO
-- 20120917.1 End change

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'GetEntitledAccounts')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).GetEntitledAccounts;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).GetEntitledAccounts >>>';
  END;
GO

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'ValidateAccountEntitlement')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).ValidateAccountEntitlement;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).ValidateAccountEntitlement >>>';
  END;
GO

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'GetEntitledIPs')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).GetEntitledIPs;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).GetEntitledIPs >>>';
  END;
GO

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'ValidateIPEntitlement')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).ValidateIPEntitlement;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).ValidateIPEntitlement >>>';
  END;
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
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_All
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_All >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneAccount')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneAccount
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneAccount >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneControlID')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneControlID
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneControlID >>>'
  END
GO
IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneAdministrator')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneAdministrator
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneAdministrator >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneBranch')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneBranch
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneBranch >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneAccountant')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneAccountant
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneAccountant >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneSeniorAdministrator')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneSeniorAdministrator
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneSeniorAdministrator >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneMinorAccount')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneMinorAccount
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneMinorAccount >>>'
  END
GO

IF EXISTS
     (SELECT
        1
      FROM
        Information_Schema.Routines
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'FUNCTION' AND
        ROUTINE_NAME = 'tvf_GetAccountID_OneInvestmentOfficer')
  BEGIN
    DROP FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneInvestmentOfficer
    PRINT '<<< DROPPED FUNCTION $(BIS_SECURITY_SCHEMA).tvf_GetAccountID_OneInvestmentOfficer >>>'
  END
GO

-- Organization

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Add_Organization')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Add_Organization;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Add_Organization >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Upd_Organization')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_Organization;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_Organization >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Del_Organization')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Del_Organization;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Del_Organization >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Get_Organization')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Get_Organization;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Get_Organization >>>';
  END;
GO

-- Secured_User

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Add_Secured_User')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Add_Secured_User;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Add_Secured_User >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Upd_Secured_User')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_Secured_User;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_Secured_User >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Del_Secured_User')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Del_Secured_User;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Del_Secured_User >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Get_Secured_User')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Get_Secured_User;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Get_Secured_User >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'SearchSecuredUsers')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).SearchSecuredUsers;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).SearchSecuredUsers >>>';
  END;
GO
-- User_Rule

IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Add_User_Rule')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Add_User_Rule;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Add_User_Rule >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Del_User_Rule')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Del_User_Rule;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Del_User_Rule >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Get_User_Rules')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Get_User_Rules;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Get_User_Rules >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Clone_UserAndRules')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Clone_UserAndRules;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Clone_UserAndRules >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'Upd_All_Access_Flag')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_All_Access_Flag;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_All_Access_Flag >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'InsertUser')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).InsertUser;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).InsertUser >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'GetQualificationColumnList')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).GetQualificationColumnList;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).GetQualificationColumnList >>>';
  END;
GO
IF EXISTS
     (SELECT
        *
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'SearchQualificationValues')
  BEGIN
    DROP PROCEDURE $(BIS_SECURITY_SCHEMA).SearchQualificationValues;
    PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).SearchQualificationValues >>>';
  END;
GO
-- ==============
-- Drop the Views
-- ==============
IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' and table_name = N'vw_UserRules')
   BEGIN
      DROP VIEW $(BIS_SECURITY_SCHEMA).vw_UserRules;
      PRINT '<<< DROPPED VIEW $(BIS_SECURITY_SCHEMA).vw_UserRules >>>';
   END;
GO
