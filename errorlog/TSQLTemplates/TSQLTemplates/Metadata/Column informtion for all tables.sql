

SELECT  * 
FROM    ( SELECT    REPLACE(LOWER(objects.type_desc), '_', ' ') AS table_type, schemas.name AS schema_name, objects.name AS table_name, 
                    columns.name AS column_name, CASE WHEN columns.is_identity = 1 THEN 'IDENTITY NOT NULL' 
                                                      WHEN columns.is_nullable = 1 THEN 'NULL' 
                                                      ELSE 'NOT NULL' 
                                                 END AS nullability, 
                   --types that have a ascii character or binary length 
                    CASE WHEN columns.is_computed = 1 THEN 'Computed' 
                         WHEN types.name IN ( 'varchar', 'char', 'varbinary' ) THEN types.name + CASE WHEN columns.max_length = -1 THEN '(max)' 
                                                                                                      ELSE '(' + CAST(columns.max_length AS VARCHAR(4)) + ')' 
                                                                                                 END 
                 
                         --types that have an unicode character type that requires length to be halved 
                         WHEN types.name IN ( 'nvarchar', 'nchar' ) THEN types.name + CASE WHEN columns.max_length = -1 THEN '(max)' 
                                                                                           ELSE '(' + CAST(columns.max_length / 2 AS VARCHAR(4)) + ')' 
                                                                                      END

                          --types with a datetime precision 
                         WHEN types.name IN ( 'time', 'datetime2', 'datetimeoffset' ) THEN types.name + '(' + CAST(columns.scale AS VARCHAR(4)) + ')'

                         --types with a precision/scale 
                         WHEN types.name IN ( 'numeric', 'decimal' ) 
                         THEN types.name + '(' + CAST(columns.precision AS VARCHAR(4)) + ',' + CAST(columns.scale AS VARCHAR(4)) + ')'

                        --timestamp should be reported as rowversion 
                         WHEN types.name = 'timestamp' THEN 'rowversion' 
                         --and the rest. Note, float is declared with a bit length, but is 
                         --represented as either float or real in types  
                         ELSE types.name 
                    END AS declared_datatype,

                   --types that have a ascii character or binary length 
                    CASE WHEN baseType.name IN ( 'varchar', 'char', 'varbinary' ) THEN baseType.name + CASE WHEN columns.max_length = -1 THEN '(max)' 
                                                   ELSE '(' + CAST(columns.max_length AS VARCHAR(4)) + ')' 
                                              END 
                
                         --types that have an unicode character type that requires length to be halved 
                         WHEN baseType.name IN ( 'nvarchar', 'nchar' ) THEN baseType.name + CASE WHEN columns.max_length = -1 THEN '(max)' 
                                                                                                 ELSE '(' + CAST(columns.max_length / 2 AS VARCHAR(4)) + ')' 
                                                                                            END

                         --types with a datetime precision 
                         WHEN baseType.name IN ( 'time', 'datetime2', 'datetimeoffset' ) THEN baseType.name + '(' + CAST(columns.scale AS VARCHAR(4)) + ')'

                         --types with a precision/scale 
                         WHEN baseType.name IN ( 'numeric', 'decimal' ) 
                         THEN baseType.name + '(' + CAST(columns.precision AS VARCHAR(4)) + ',' + CAST(columns.scale AS VARCHAR(4)) + ')'

                         --timestamp should be reported as rowversion 
                         WHEN baseType.name = 'timestamp' THEN 'rowversion' 
                         --and the rest. Note, float is declared with a bit length, but is 
                         --represented as either float or real in types 
                         ELSE baseType.name 
                    END AS base_datatype, CASE WHEN EXISTS ( SELECT * 
                                                             FROM   sys.key_constraints 
                                                                    JOIN sys.indexes 
                                                                        ON key_constraints.parent_object_id = indexes.object_id 
                                                                           AND key_constraints.unique_index_id = indexes.index_id 
                                                                    JOIN sys.index_columns 
                                                                        ON index_columns.object_id = indexes.object_id 
                                                                           AND index_columns.index_id = indexes.index_id 
                                                             WHERE  key_constraints.type = 'PK' 
                                                                    AND columns.column_id = index_columns.column_id 
                                                                    AND columns.OBJECT_ID = index_columns.OBJECT_ID ) THEN 1 
                                               ELSE 0 
                                          END AS primary_key_column, columns.column_id, default_constraints.definition AS default_value, 
                    check_constraints.definition AS column_check_constraint, 
                    CASE WHEN EXISTS ( SELECT   * 
                                       FROM     sys.check_constraints AS cc 
                                       WHERE    cc.parent_object_id = columns.OBJECT_ID 
                                                AND cc.definition LIKE '%~[' + columns.name + '~]%' ESCAPE '~' 
                                                AND cc.parent_column_id = 0 ) THEN 1 
                         ELSE 0 
                    END AS table_check_constraint_reference 
          FROM      sys.columns 
                    JOIN sys.types 
                        ON columns.user_type_id = types.user_type_id 
                    JOIN sys.types AS baseType 
                        ON columns.system_type_id = baseType.system_type_id 
                           AND baseType.user_type_id = baseType.system_type_id 
                    JOIN sys.objects 
                            JOIN sys.schemas 
                                   ON schemas.schema_id = objects.schema_id 
                        ON objects.object_id = columns.OBJECT_ID 
                    LEFT OUTER JOIN sys.default_constraints 
                        ON default_constraints.parent_object_id = columns.object_id 
                              AND default_constraints.parent_column_id = columns.column_id 
                    LEFT OUTER JOIN sys.check_constraints 
                        ON check_constraints.parent_object_id = columns.object_id 
                             AND check_constraints.parent_column_id = columns.column_id ) AS rows 
WHERE   table_type = 'user table' 
              AND schema_name LIKE '%' 
              AND table_name LIKE '%' 
              AND column_name LIKE '%' 
              AND nullability LIKE '%' 
              AND base_datatype LIKE '%' 
              AND declared_datatype LIKE '%' 
ORDER BY table_type, schema_name, table_name, column_id  