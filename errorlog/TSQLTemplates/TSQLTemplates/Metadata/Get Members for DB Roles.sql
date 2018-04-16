
select  dpr.name as RoleName,
        dprm.name as MemberName,
        dprm.type_desc as MemberType
from sys.Database_Role_Members drm
    inner join sys.Database_Principals dprm on dprm.principal_id = drm.member_principal_id
    inner join sys.database_principals dpr on dpr.principal_id = drm.role_principal_id