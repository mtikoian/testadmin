/***
================================================================================
 Author      : <Author name,,>
 Description : Drops the service broker message type <Message type name,,>

 Required variables:
 ====================
 Message type name - The name of the message type.
  
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
IF EXISTS (SELECT 1 FROM sys.service_message_types WHERE name = '<Message type name,,>')
  DROP MESSAGE TYPE [<Message type name,,>];