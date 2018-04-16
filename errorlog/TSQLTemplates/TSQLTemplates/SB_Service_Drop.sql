/***
================================================================================
 Author      : <Author name,,>
 Description : Drops the Service Broker Service <Service name,,>

 Required variables:
 ====================
 Service name - The name of the Service
 
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
IF EXISTS (SELECT 1 FROM sys.services WHERE name = '<Service name,,>')
  DROP SERVICE [<Service name,,>];