CREATE FUNCTION dbo.isfRemoveNonAlphaChars
        (@pString VARCHAR(8000))
RETURNS TABLE WITH SCHEMABINDING AS
 RETURN
 --===== "Inline" CTE Driven "Tally Table" produces values from 1 up to 10,000...
      -- enough to cover VARCHAR(8000)
  WITH E1(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),                          --10E+1 or 10 rows
       E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
       E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
 cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                     -- for both a performance gain and prevention of accidental "overruns"
                 SELECT TOP (ISNULL(DATALENGTH(@pString),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
                )
 SELECT CleanString = 
        (
         SELECT SUBSTRING(@pString,t.N,1)
           FROM cteTally t --No WHERE clause needed because of TOP above
          WHERE SUBSTRING(@pString,t.N,1) LIKE '[a-z ''-]'
          ORDER BY t.N
            FOR XML PATH(''), TYPE
        ).value('text()[1]', 'varchar(8000)')
;