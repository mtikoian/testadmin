

select distinct sc.id, so.Name,sc.text as proc_text  
from syscomments sc
    inner join sysobjects so on so.id = sc.id
where sc.text like '%portfolio_performance%'   
order by so.Name             


[dbo].[P_mdb_MDAposperflistdyn_get]


-- Check dynamic strings

SELECT OBJECT_NAME(object_id) AS [Procedure Name],
  CASE
      WHEN sm.definition LIKE '%EXEC (%' OR sm.definition LIKE '%EXEC(%' THEN 'WARNING: code contains EXEC'
      WHEN sm.definition LIKE '%EXECUTE (%' OR sm.definition LIKE '%EXECUTE(%' THEN 'WARNING: code contains EXECUTE'
  END AS [Dynamic Strings],
  CASE
      WHEN execute_as_principal_id IS NOT NULL THEN N'WARNING: EXECUTE AS ' + user_name(execute_as_principal_id)
      ELSE 'Code to run as caller – check connection context'
  END AS [Execution Context Status]
FROM sys.sql_modules AS sm
ORDER BY [Procedure Name]