/* Finds the date that the latest full backup was taken */
WITH FullBackupSet AS
(
  select  ROW_NUMBER() OVER (PARTITION BY database_name ORDER BY backup_start_date DESC) AS RowNum,
          database_name,
          backup_start_date 
  from    msdb.dbo.backupset where type = 'D'
),
DiffBackupSet AS
(
  select  ROW_NUMBER() OVER (PARTITION BY database_name ORDER BY backup_start_date DESC) AS RowNum,
          database_name,
          backup_start_date 
  from    msdb.dbo.backupset where type = 'I'
)
SELECT  fbs.database_name,
        fbs.backup_start_date AS full_backup_date,
        dbs.backup_start_date AS diff_backup_date
FROM    FullBackupSet fbs
          JOIN DiffBackupSet dbs
            ON fbs.database_name = dbs.database_name
WHERE   fbs.RowNum = 1 AND
        dbs.RowNum = 1;