SET NOCOUNT ON

SELECT      'Primary' + '<1>' +
                CASE WHEN E.name IS NULL THEN '0' ELSE '1' END + '<2>' +
                A.primary_server + '<3>' +
                B.primary_database + '<4>' +
                C.secondary_server + '<5>' +
                C.secondary_database + '<6>' +
                B.monitor_server + '<7>' +
                B.backup_directory + '<8>' +
                B.backup_share + '<9>' +
                ISNULL(B.last_backup_file, 'NULL') + '<10>' +
                ISNULL(CONVERT(varchar(30), B.last_backup_date, 120), 'NULL') + '<11>' +
                'NULL' + '<12>' +
                'NULL' + '<13>' +
                'NULL' + '<14>' +
                'NULL' + '<15>' +
                ISNULL(CAST(B.backup_retention_period AS varchar(20)), 'NULL') + '<16>' +
                ISNULL(D.name, 'NULL') + '<17>' +
                'NULL' + '<18>' +
                'NULL'
FROM        msdb.dbo.log_shipping_monitor_primary A
                JOIN msdb.dbo.log_shipping_primary_databases B ON A.primary_id = B.primary_id
                JOIN msdb.dbo.log_shipping_primary_secondaries C ON A.primary_id = C.primary_Id
                LEFT JOIN msdb.dbo.sysjobs D ON B.backup_job_id = D.job_Id
                LEFT JOIN master.sys.databases E ON A.primary_database = E.name
UNION ALL                
SELECT      'Secondary' + '<1>' +
                CASE WHEN E.name IS NULL THEN '0' ELSE '1' END + '<2>' +
                A.primary_server + '<3>' +
                A.primary_database + '<4>' +
                A.secondary_server + '<5>' +
                A.secondary_database + '<6>' +
                B.monitor_server + '<7>' +
                B.backup_source_directory + '<8>' +
                B.backup_destination_directory + '<9>' +
                'NULL' + '<10>' +
                'NULL' + '<11>' +
                ISNULL(A.last_copied_file, 'NULL') + '<12>' +
                ISNULL(CONVERT(varchar(30), A.last_copied_date, 120), 'NULL') + '<13>' +
                ISNULL(A.last_restored_file, 'NULL') + '<14>' +
                ISNULL(CONVERT(varchar(30), A.last_restored_date, 120), 'NULL') + '<15>' +
                CAST(B.file_retention_period AS varchar(10)) + '<16>' +
                'NULL' + '<17>' +
                ISNULL(C.name, 'NULL') + '<18>' +
                ISNULL(D.name, 'NULL')
FROM        msdb.dbo.log_shipping_monitor_secondary A
                JOIN msdb.dbo.log_shipping_secondary B ON A.secondary_id = B.secondary_id
                LEFT JOIN msdb.dbo.sysjobs C ON B.copy_job_id = C.job_id
                LEFT JOIN msdb.dbo.sysjobs D ON B.restore_job_id = D.job_id
                LEFT JOIN master.sys.databases E ON A.secondary_database = E.name



