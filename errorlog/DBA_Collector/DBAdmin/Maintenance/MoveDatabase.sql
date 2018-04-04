select  db_name(database_id) db_name,
        physical_name
from    sys.master_files
order by physical_name

EXEC dbo.DatabaseBackup @databases='fund_reporting', @backupSoftware='Litespeed', @backupType='DIFF', @Verify='Y';
ALTER DATABASE fund_reporting SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
EXEC sp_rename 'fund_reporting','fund_reporting_OLD','database';
EXEC sp_rename 'fund_reporting_NEW','fund_reporting','database';

DROP DATABASE fund_reporting_OLD;