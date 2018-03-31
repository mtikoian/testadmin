-- =============================================
-- Pushes security based on the current environment variable setting
-- =============================================

PRINT '******************************* Deplying Permissions for DeployType = $(DeployType) ************************************'

IF ( '$(DeployType)' = 'Dev')
BEGIN
 :r .\SecurityAdditionsDEV.sql
END
ELSE IF ( '$(DeployType)' = 'QA')
BEGIN
 :r .\SecurityAdditionsQA.sql
END
ELSE IF ( '$(DeployType)' = 'Production')
BEGIN
 :r .\SecurityAdditionsProduction.sql
END
ELSE
BEGIN
 :r .\SecurityAdditionsDefault.sql
END
