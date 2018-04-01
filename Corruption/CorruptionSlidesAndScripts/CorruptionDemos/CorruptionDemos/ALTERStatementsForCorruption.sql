USE master;

/* Set the database to SINGLE_USER to allow you to take it offline 
   Once the database is offline, open the datafile in a hex editor
   Make a change to the file at the offset return from query 
   7 - GetPageIIDandOffset.sql 
   I use vxi32, available here
   http://www.chmaas.handshake.de/delphi/freeware/xvi32/xvi32.htm */

ALTER DATABASE CorruptDemoDB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

ALTER DATABASE CorruptDemoDB
SET OFFLINE;

/* Once you have changed, saved, and closed the data file
   bring it online and set it to MULTI_USER */

ALTER DATABASE CorruptDemoDB
SET ONLINE;

ALTER DATABASE CorruptDemoDB
SET MULTI_USER;