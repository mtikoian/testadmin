/***
================================================================================
 Author      : <Author name,,>
 Description : Creates the Service Broker contract <Contract name,,>

 Required variables:
 ====================
 Contract name - The name of the contract
 Message type name - the name of the message type used by the contract
 
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
IF NOT EXISTS (SELECT 1 FROM sys.service_contracts WHERE name = '<Contract name,,>')
  CREATE CONTRACT [<Contract name,,>] ([<Message type name,,>] SENT BY ANY);