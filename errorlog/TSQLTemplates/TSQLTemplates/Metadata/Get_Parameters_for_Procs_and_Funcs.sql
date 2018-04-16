
SELECT 'Routine_Name' = ao.[name],
       'Parameter_name' = ap.name,
       'Type' = type_name (ap.user_type_id),
       'Length' = ap.max_length,
       'Prec' =
           CASE
               WHEN type_name (ap.system_type_id) = 'uniqueidentifier' THEN ap.precision
               ELSE OdbcPrec(ap.system_type_id, ap.max_length, ap.precision)
           END,
       'Scale' = OdbcScale (system_type_id, ap.scale),
       'Param_order' = ap.parameter_id,
       'Collation' =
           CONVERT (sysname,
                    CASE WHEN ap.system_type_id IN (35, 99, 167, 175, 231, 239) THEN ServerProperty ('collation') END)
  FROM sys.all_objects ao
       INNER JOIN sys.schemas ss
           ON ao.[schema_id] = ss.[schema_id]
       LEFT OUTER JOIN sys.all_parameters ap
           ON ao.[object_id] = ap.[object_id]
--WHERE ss.[name] = 'RAS' AND ao.type IN ('P', 'FN')
where ao.Type IN ('P', 'FN')
                