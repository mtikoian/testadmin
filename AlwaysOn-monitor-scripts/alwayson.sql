--Remove a Primary Database from an Availability Group
ALTER AVAILABILITY GROUP MyAG REMOVE DATABASE Db6; 
--Remove an Availability Group 
DROP AVAILABILITY GROUP MyAG;  
--Perform a planned manual failover of an availability group


--Forced manual failover with data loss
ALTER AVAILABILITY GROUP [ag1] FORCE_FAILOVER_ALLOW_DATA_LOSS;

ALTER AVAILABILITY GROUP [ag1] 
     SET (ROLE = SECONDARY); 
     
ALTER AVAILABILITY GROUP ag1 FORCE_FAILOVER_ALLOW_DATA_LOSS; 

--Resume an Availability Database

ALTER DATABASE database_name SET HADR RESUME
--Suspend an Availability Database
ALTER DATABASE database_name SET HADR SUSPEND

--Take an Availability Group Offline
ALTER AVAILABILITY GROUP AccountsAG OFFLINE;  

--Remove a Secondary Database from an Availability Group
ALTER DATABASE MyDb2 SET HADR OFF;  
GO  

--Remove a Secondary Replica from an Availability Group
ALTER AVAILABILITY GROUP MyAG REMOVE REPLICA ON 'COMPUTER02\HADR_INSTANCE';  

--Perform a planned manual failover of an availability group
ALTER AVAILABILITY GROUP MyAg FAILOVER; 
--Perform a Forced Manual Failover of an Availability Group
ALTER AVAILABILITY GROUP AccountsAG FORCE_FAILOVER_ALLOW_DATA_LOSS;  
--Change the HADR Cluster Context of Server Instance
ALTER SERVER CONFIGURATION SET HADR CLUSTER CONTEXT = 'clus01.xyz.com';  
SELECT cluster_name FROM sys.dm_hadr_cluster  

--Change the Session-Timeout Period for an Availability Replica
ALTER AVAILABILITY GROUP AccountsAG   
   MODIFY REPLICA ON 'INSTANCE09' WITH (SESSION_TIMEOUT = 15);  
   
--Add a Secondary Replica to an Availability Group
ALTER AVAILABILITY GROUP MyAG ADD REPLICA ON 'COMPUTER04'   
   WITH (  
         ENDPOINT_URL = 'TCP://COMPUTER04.Adventure-Works.com:5022',  
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,  
         FAILOVER_MODE = MANUAL  
         );  
         
 
 /*Troubleshoot a Failed Add-File Operation 
 Remove the secondary database from the availability group. For more information, see Remove a Secondary Database from an Availability Group (SQL Server).

On the existing secondary database, restore a full backup of the filegroup that contains the added file to the secondary database, using WITH NORECOVERY and WITH MOVE (specifying the file path on the server instance that hosts the secondary replica). For more information, see Restore a Database to a New Location (SQL Server).

Back up the transaction log that contains the add-file operation on the primary database, and manually restore the log backup on the secondary database using WITH NORECOVERY and WITH MOVE.

Prepare the secondary database for re-joining the availability group, by restoring, WITH NO RECOVERY, any other outstanding log backups from the primary database.

Rejoin the secondary database to the availability group. For more information, see Join a Secondary Database to an Availability Group (SQL Server).
 */   
 
 --upgrade AG's
 https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/upgrading-always-on-availability-group-replica-instances
 
 