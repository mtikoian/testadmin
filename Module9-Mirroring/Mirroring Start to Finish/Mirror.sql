/* Make sure the DB backup and log backup have been restored without recovery on the mirror first */
USE MASTER

/* This retrieves information on existing mirroring endpoints.  There can only be one per instance.
sys.tcp_endpoints contains info on ALL system endpoint regardless of function.
sys.database_mirroring_endpoints contains mirroring endpoints, but does not have the IP and port information.
This is why we join TE to get the IP info. */
SELECT DME.name, DME.protocol_desc, DME.type_desc, DME.state_desc, DME.role_desc,
		TE.port, TE.ip_address
FROM sys.database_mirroring_endpoints AS DME
Inner Join sys.tcp_endpoints AS TE
ON TE.endpoint_id = DME.endpoint_id

/* Make sure a mirroring end point does not already exist and then create one on the Mirror */
IF Not Exists (SELECT 1 FROM sys.database_mirroring_endpoints)
	BEGIN
		CREATE ENDPOINT [Mirror_Inst01] /* InstanceName/MachineName_MirrorEP is a good naming convention */
			STATE = STARTED
			AS TCP (LISTENER_PORT = 5023, LISTENER_IP = ALL) /* Specify Listener_IP if using a dedicated NIC for Mirroring */
			FOR Database_Mirroring (ROLE = All); /* Role can be partner, witness, or all. */
			/* Using All means you do not have to alter the end point if the server function changes */
	END
	
/* Create a login on the Mirror for the account running the SQL Service on the Principal. */
CREATE LOGIN [MirrorInstance\PrincipalServiceAccount] FROM WINDOWS;

/* Grant Connect on Mirror Endpoint to Principal Login */
GRANT CONNECT ON ENDPOINT::[Mirror_Inst01] TO [MirrorInstance\PrincipalServiceAccount]

/* Set the principal partner on the mirror */
ALTER DATABASE MyDB
SET PARTNER = 'TCP://PrincipalFQDN:5022';

/* Create the "Database Mirroring Monitor Job"
Mirroring setup via GUI creates this, but via T-SQL this command must be
used to create the job.  Default schedule is to run once every minute, but
uncomment the number parameter and change to whatever you want in minutes.
You should run this on both the principal and mirror to monitor activity
on both sides of the mirror */
USE master
exec sp_dbmmonitoraddmonitoring --10

/* This code will perform a failover to test out the configuration. It must be run from the principal
USE MASTER
ALTER DATABASE MyDB
SET PARTNER FAILOVER
*/