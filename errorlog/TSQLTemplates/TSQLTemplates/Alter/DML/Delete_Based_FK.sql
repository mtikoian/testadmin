/*Thus script clears all data from a database without requiring you to disable foreign keys
Basically, it orders all the tables according to FKs so that it deletes from them in the correct order.*/
SET NOCOUNT ON;
DECLARE    @schemaName SYSNAME;
DECLARE    @tableName  SYSNAME;
DECLARE    @level      INT;
DECLARE t_cur CURSOR FOR
WITH fk_tables AS (
    SELECT    s1.name AS from_schema    
    ,        o1.Name AS from_table    
    ,        s2.name AS to_schema    
    ,        o2.Name AS to_table    
    FROM    sys.foreign_keys fk    
    INNER    JOIN sys.objects o1                                 ON        fk.parent_object_id = o1.OBJECT_ID    
    INNER    JOIN sys.schemas s1                                 ON        o1.schema_id = s1.schema_id    
    INNER    JOIN sys.objects o2                                 ON        fk.referenced_object_id = o2.OBJECT_ID    
    INNER    JOIN sys.schemas s2                                 ON        o2.schema_id = s2.schema_id    
    /*For the purposes of finding dependency hierarchy we're not worried about self-referencing tables*/
    WHERE    NOT    (    s1.name = s2.name                 
            AND        o1.name = o2.name)
)
,ordered_tables AS
(        SELECT    s.name AS schemaName
        ,        t.name AS tableName
        ,        0 AS LEVEL    
        FROM    (    SELECT    *                
                    FROM    sys.tables                 
                    WHERE    name <> 'sysdiagrams') t    
        INNER    JOIN sys.schemas s                                  ON        t.schema_id = s.schema_id    
        LEFT    OUTER JOIN fk_tables fk                               ON        s.name = fk.from_schema    
                                                                       AND   t.name = fk.from_table    
        WHERE    fk.from_schema IS NULL
        UNION    ALL
        SELECT    fk.from_schema
        ,        fk.from_table
        ,        ot.LEVEL + 1    
        FROM    fk_tables fk    
        INNER    JOIN ordered_tables ot                              ON        fk.to_schema = ot.schemaName    
                                                                       AND   fk.to_table = ot.tableName
)
SELECT    DISTINCT    ot.schemaName,ot.tableName,ot.LEVEL
FROM    ordered_tables ot
INNER    JOIN (
        SELECT    schemaName,tableName,MAX(LEVEL) maxLevel        
        FROM    ordered_tables        
        GROUP    BY schemaName,tableName
        ) mx
ON        ot.schemaName = mx.schemaName
AND        ot.tableName = mx.tableName
AND        mx.maxLevel = ot.LEVEL
ORDER BY LEVEL DESC; 
OPEN t_cur;
FETCH NEXT FROM t_cur INTO @schemaName,@tableName,@level;
WHILE @@FETCH_STATUS = 0
BEGIN
       DECLARE @ParmDefinition NVARCHAR(500)   ;
       DECLARE @vSQL           NVARCHAR(MAX)   ;
       DECLARE @vRowCount      INT             ;
       SET     @vSQL = 'DELETE FROM [' + @schemaName + '].[' + @tableName + '];';
       SET     @vSQL = @vSQL + 'SET @vRowCount_OUT = @@ROWCOUNT;'
       SET     @ParmDefinition = '@vRowCount_OUT INT OUTPUT';
       EXEC    sp_executesql @vSQL,@ParmDefinition,@vRowCount_OUT=@vRowCount OUTPUT;
       PRINT   CONVERT(NVARCHAR(100),@vRowCount) + ' rows deleted from [' +  @schemaName + '].[' + @tableName + ']';
       FETCH NEXT FROM t_cur INTO @schemaName,@tableName,@level;
END

CLOSE t_cur;
DEALLOCATE t_cur;