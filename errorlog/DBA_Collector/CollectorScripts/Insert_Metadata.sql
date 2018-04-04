SET NOCOUNT ON
 SELECT cast(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as varchar(128))  + CHAR(9) + 
 CAST(ISNULL(SERVERPROPERTY('InstanceName'), 'default')  as varchar(128))  + CHAR(9) + 
 isnull(LOCAL_NET_ADDRESS,'')  
 
 FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID 