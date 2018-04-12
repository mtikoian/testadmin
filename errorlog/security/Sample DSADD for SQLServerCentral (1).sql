select 
'dsadd group cn=' + [name] + '_RO,ou=SQL_Groups,ou=User_Groups,dc=int,dc=SampleCompanyinc,dc=com -secgrp yes
dsadd group cn=' + [name] + '_RW,ou=SQL_Groups,ou=User_Groups,dc=int,dc=SampleCompanyinc,dc=com -secgrp yes
dsadd group cn=' + [name] + '_RWX,ou=SQL_Groups,ou=User_Groups,dc=int,dc=SampleCompanyinc,dc=com -secgrp yes
dsadd group cn=' + [name] + '_DBO,ou=SQL_Groups,ou=User_Groups,dc=int,dc=SampleCompanyinc,dc=com -secgrp yes'
from sysdatabases
where not exists (select 1 from sys.server_principals where [name] like 'SampleCompany\' + sysdatabases.[name] + '_RO')
and name not in ('master','model','tempdb','msdb','distribution','litespeedlocal','ReportServer','ReportserverTempDB')

