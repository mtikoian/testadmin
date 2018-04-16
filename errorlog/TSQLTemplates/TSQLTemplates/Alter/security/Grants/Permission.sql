USE NETIKIP
GO


/***
================================================================================
 Name        : PositinHolder_Permission
 Author      : ppremkumar - 08/22/2013
 Description : Execute Permission statement for the Stored Procedures for Position Holder Screen
===============================================================================
 Revisions    :
--------------------------------------------------------------------------------
 Ini			|   Date		|	 Description
 ppremkumar			08/22/2013		 Initial Version
--------------------------------------------------------------------------------
SELECT * FROM dw_function_item WHERE fn_id = 'HoldPos'
================================================================================
***/


IF NOT EXISTS (SELECT  1 FROM SYS.DATABASE_PERMISSIONS p
									INNER JOIN SYS.OBJECTS o ON o.OBJECT_ID = p.major_id
									INNER JOIN SYS.SCHEMAS ss ON ss.schema_id = o.schema_id
								WHERE OBJECT_NAME(p.major_id) = 'sp_DomainValue' AND
								   ss.NAME = 'dbo'
								  AND USER_NAME(grantee_principal_id) = 'netikapp_user'
								  AND p.permission_name = 'Execute')
BEGIN 
GRANT EXECUTE ON dbo.sp_DomainValue TO netikapp_user
END

GO
IF EXISTS (SELECT  1 FROM SYS.DATABASE_PERMISSIONS p
									INNER JOIN SYS.OBJECTS o ON o.OBJECT_ID = p.major_id
									INNER JOIN SYS.SCHEMAS ss ON ss.schema_id = o.schema_id
								WHERE OBJECT_NAME(p.major_id) = 'sp_DomainValue' AND
								   ss.NAME = 'dbo'
								  AND USER_NAME(grantee_principal_id) = 'netikapp_user'
								  AND p.permission_name = 'Execute')
BEGIN 
PRINT 'GRANT EXECUTE ON dbo.sp_DomainValue TO netikapp_user sucessfully'
END
GO

IF NOT EXISTS (SELECT  1 FROM SYS.DATABASE_PERMISSIONS p
									INNER JOIN SYS.OBJECTS o ON o.OBJECT_ID = p.major_id
									INNER JOIN SYS.SCHEMAS ss ON ss.schema_id = o.schema_id
								WHERE OBJECT_NAME(p.major_id) = 'sp_PositionDetail' AND
								   ss.NAME = 'dbo'
								  AND USER_NAME(grantee_principal_id) = 'netikapp_user'
								  AND p.permission_name = 'Execute')
BEGIN 
GRANT EXECUTE ON dbo.sp_PositionDetail TO netikapp_user
END

GO
IF EXISTS (SELECT  1 FROM SYS.DATABASE_PERMISSIONS p
									INNER JOIN SYS.OBJECTS o ON o.OBJECT_ID = p.major_id
									INNER JOIN SYS.SCHEMAS ss ON ss.schema_id = o.schema_id
								WHERE OBJECT_NAME(p.major_id) = 'sp_DomainValue' AND
								   ss.NAME = 'dbo'
								  AND USER_NAME(grantee_principal_id) = 'netikapp_user'
								  AND p.permission_name = 'Execute')
BEGIN 
PRINT 'GRANT EXECUTE ON dbo.sp_PositionDetail TO netikapp_user sucessfully'
END
GO
