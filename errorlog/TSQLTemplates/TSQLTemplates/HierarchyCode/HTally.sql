--===== Create the HTally table to be used for splitting SortPath
 SELECT TOP 1000 --(4 * 1000 = VARBINARY(4000) in length)
        N = ISNULL(CAST(
                (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))-1)*4+1
            AS INT),0)
   INTO dbo.HTally
   FROM master.sys.all_columns ac1
  CROSS JOIN master.sys.all_columns ac2
;
--===== Add the quintessential PK for performance.
  ALTER TABLE dbo.HTally
    ADD CONSTRAINT PK_HTally 
        PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100
;