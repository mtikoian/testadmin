--_______________________________________________________________________________________________________________________
/**********************************************************************************************************************
 Purpose:
 Returns a single result set similar to sp_Space used for all user tables at once.
&#160;
 Notes:
 1. May be used as a view, stored procedure, or table-valued funtion.
 2. Must comment out 1 "Schema" in the SELECT list below prior to use.  See the adjacent comments for more info.
&#160;
 Revision History:
 Rev 00 - 22 Jan 2007 - Jeff Moden
                      - Initital creation for SQL Server 2000
 Rev 01 - 11 Mar 2007 - Jeff Moden
                      - Add automatic page size determination for future compliance
 Rev 02 - 05 Jan 2008 - Jeff Moden
                      - Change "Owner" to "Schema" in output.  Add optional code per Note 2 to find correct schema name
**********************************************************************************************************************/
--===== Ensure that all row counts, etc is up to snuff
     -- Obviously, this will not work in a view or UDF and should be removed if in a view or UDF. External code should 
     -- execute the command below prior to retrieving from the view or UDF.
   DBCC UPDATEUSAGE(0) WITH COUNT_ROWS, NO_INFOMSGS 
--&#160;
--===== Return the single result set similar to what sp_SpaceUsed returns for a table, but more
 SELECT DBName       = DB_NAME(),
        --SchemaName   = SCHEMA_NAME(so.UID), --Comment out if for SQL Server 2000
        SchemaName   = USER_NAME(so.UID),   --Comment out if for SQL Server 2005
        TableName    = so.Name,
        TableID      = so.ID,
        MinRowSize   = MIN(si.MinLen),
        MaxRowSize   = MAX(si.XMaxLen),
        ReservedKB   = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Reserved       ELSE 0 END) * pkb.PageKB,
        DataKB       = SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.DPages         ELSE 0 END) * pkb.PageKB
                     + SUM(CASE WHEN si.IndID IN (    255) THEN ISNULL(si.Used,0) ELSE 0 END) * pkb.PageKB,
        IndexKB      = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Used           ELSE 0 END) * pkb.PageKB
                     - SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.DPages         ELSE 0 END) * pkb.PageKB
                     - SUM(CASE WHEN si.IndID IN (    255) THEN ISNULL(si.Used,0) ELSE 0 END) * pkb.PageKB,
        UnusedKB     = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Reserved       ELSE 0 END) * pkb.PageKB
                     - SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Used           ELSE 0 END) * pkb.PageKB,
        Rows         = SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.Rows           ELSE 0 END),
        RowModCtr    = MIN(si.RowModCtr),
        HasTextImage = MAX(CASE WHEN si.IndID IN (    255) THEN 1                 ELSE 0 END),
        HasClustered = MAX(CASE WHEN si.IndID IN (  1    ) THEN 1                 ELSE 0 END)
   FROM dbo.SysObjects so,
        dbo.SysIndexes si,
        (--Derived table finds page size in KB according to system type
         SELECT Low/1024 AS PageKB --1024 is a binary Kilo-byte
           FROM Master.dbo.spt_Values 
          WHERE Number = 1   --Identifies the primary row for the given type
            AND Type   = 'E' --Identifies row for system type
        ) pkb
  WHERE si.ID = so.ID
    AND si.IndID IN (0, --Table w/o Text or Image Data
                     1, --Table with clustered index
                   255) --Table w/ Text or Image Data
    AND so.XType = 'U'  --User Tables
    AND PERMISSIONS(so.ID) <> 0 
  GROUP BY so.Name,
           so.UID,
           so.ID,
           pkb.PageKB
  ORDER BY ReservedKB DESC
  
  
  /**********************************************************************************************************************
 Purpose:
 Returns a single result set similar to sp_Space used for all user tables at once.

 Notes:
 1. May be used as a view, stored procedure, or table-valued funtion.
 2. Must comment out 1 "Schema" in the SELECT list below prior to use.  See the adjacent comments for more info.

 Revision History:
 Rev 00 - 22 Jan 2007 - Jeff Moden
                      - Initital creation for SQL Server 2000
 Rev 01 - 11 Mar 2007 - Jeff Moden
                      - Add automatic page size determination for future compliance
 Rev 02 - 05 Jan 2008 - Jeff Moden
                      - Change "Owner" to "Schema" in output.  Add optional code per Note 2 to find correct schema name
**********************************************************************************************************************/
--===== Ensure that all row counts, etc is up do snuff
     -- Obviously, this will not work in a view or UDF and should be removed if in a view or UDF. External code should 
     -- execute the command below prior to retrieving from the view or UDF.
--   DBCC UPDATEUSAGE(0)

----===== Return the single result set similar to what sp_SpaceUsed returns for a table, but more
-- SELECT DBName       = DB_NAME(),
--        SchemaName   = SCHEMA_NAME(so.UID), --Comment out if for SQL Server 2000
--        --SchemaName   = USER_NAME(so.UID),   --Comment out if for SQL Server 2005
--        TableName    = so.Name,
--        TableID      = so.ID,
--        MinRowSize   = MIN(si.MinLen),
--        MaxRowSize   = MAX(si.XMaxLen),
--        ReservedKB   = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Reserved       ELSE 0 END) * pkb.PageKB,
--        DataKB       = SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.DPages         ELSE 0 END) * pkb.PageKB
--                     + SUM(CASE WHEN si.IndID IN (    255) THEN ISNULL(si.Used,0) ELSE 0 END) * pkb.PageKB,
--        IndexKB      = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Used           ELSE 0 END) * pkb.PageKB
--                     - SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.DPages         ELSE 0 END) * pkb.PageKB
--                     - SUM(CASE WHEN si.IndID IN (    255) THEN ISNULL(si.Used,0) ELSE 0 END) * pkb.PageKB,
--        UnusedKB     = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Reserved       ELSE 0 END) * pkb.PageKB
--                     - SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Used           ELSE 0 END) * pkb.PageKB,
--        Rows         = SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.Rows           ELSE 0 END),
--        RowModCtr    = MIN(si.RowModCtr),
--        HasTextImage = MAX(CASE WHEN si.IndID IN (    255) THEN 1                 ELSE 0 END),
--        HasClustered = MAX(CASE WHEN si.IndID IN (  1    ) THEN 1                 ELSE 0 END)
--   FROM dbo.SysObjects so,
--        dbo.SysIndexes si,
--        (--Derived table finds page size in KB according to system type
--         SELECT Low/1024 AS PageKB --1024 is a binary Kilo-byte
--           FROM Master.dbo.spt_Values 
--          WHERE Number = 1   --Identifies the primary row for the given type
--            AND Type   = 'E' --Identifies row for system type
--        ) pkb
--  WHERE si.ID = so.ID
--    AND si.IndID IN (0, --Table w/o Text or Image Data
--                     1,
--                   255) --Table w/ Text or Image Data
--    AND so.XType = 'U'  --User Tables
--    AND PERMISSIONS(so.ID) <> 0 
--  GROUP BY so.Name,
--           so.UID,
--           so.ID,
--           pkb.PageKB
--  ORDER BY ReservedKB DESC
