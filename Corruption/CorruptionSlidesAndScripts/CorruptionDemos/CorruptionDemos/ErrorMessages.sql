Object ID 245575913, index ID 1, partition ID 72057594040614912, alloc unit ID 72057594045857792 (type In-row data): 
Page (1:301) could not be processed.  See other errors for details.

Msg 8939, Level 16, State 98, Line 2
Table error: Object ID 245575913, index ID 1, partition ID 72057594040614912, alloc unit ID 72057594045857792 
(type In-row data), page (1:301). Test (IS_OFF (BUF_IOERR, pBUF->bstat)) failed. Values are 133129 and -4.

Msg 824, Level 24, State 2, Line 6
SQL Server detected a logical consistency-based I/O error: 
incorrect checksum (expected: 0xcbdc9dba; actual: 0xce5c9dba). 
It occurred during a read of page (1:301) in database ID 10 at offset 0x0000000025a000 
in file 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CorruptDemoDB.mdf'.  
Additional messages in the SQL Server error log or system event log may provide more detail. 
This is a severe error condition that threatens database integrity and must be corrected immediately. 
Complete a full database consistency check (DBCC CHECKDB). 
This error can be caused by many factors; for more information, see SQL Server Books Online.
