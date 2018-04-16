/***
================================================================================
 Author      : <Author name,,>
 Description : Creates the Service Broker queue <Queue name,,>

 Required variables:
 ====================
 Queue name - The name of the Queue
 Queue schema - The name of the schema that holds the queue
 
 See http://msdn.microsoft.com/en-us/library/ms187744.aspx for details.

 Revision: $Rev$
 URL: $URL$
 Last Checked in: $Author$
===============================================================================

Revisions    :
--------------------------------------------------------------------------------
 Ini|   Date   | Description
--------------------------------------------------------------------------------

================================================================================
***/
IF NOT EXISTS (SELECT 1 
               FROM sys.service_queues sq JOIN sys.schemas sch
                      ON sq.schema_id = sch.schema_id
               WHERE sq.name = '<Queue name,,>'
                     AND sch.name = '<Queue Schema,,>')
  CREATE Queue <Queue Schema,,>.[<Queue name,,>] WITH 
    STATUS = ON,
    RETENTION = OFF;      