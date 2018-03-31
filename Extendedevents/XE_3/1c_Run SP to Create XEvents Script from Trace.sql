/*============================================================================
  File:     1c_Run SP to Create XEvents Script from Trace.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2015, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

EXECUTE sp_SQLskills_ConvertTraceToExtendedEvents 
		@TraceID = 2, 
		@SessionName = 'XE_ReadsFilter_Trace', 
		@PrintOutput = 1, 
		@Execute = 0;
