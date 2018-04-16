/***
================================================================================
 Author      : <Author name,,>
 Description : Drops the Service Broker contract <Contract name,,>

 Required variables:
 ====================
 Contract name - The name of the contract
 
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
IF EXISTS (SELECT 1 FROM sys.service_contracts WHERE name = '<Contract name,,>')
  DROP CONTRACT [<Contract name,,>];