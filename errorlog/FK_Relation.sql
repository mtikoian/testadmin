
/*
 
Because I usually deal with databases consisting of hundreds of tables, I developed the stored procedure attached to try to make my life easier. Hope you enjoy it. Any comments about it are welcome.
 
The stored procedure attached reads SQL server system tables and generates some valuable outputs, to name:
 
   1. List of tables, including their treeLevel (nodeLevel)
      treeLevel (nodeLevel): defined based on existing relationships between tables
      Example: table A relates to table B one to many; table B relates to table C one to many. Based on the relationships table A is on nodeLevel 1; table B on nodeLevel 2 and table C on nodeLevel 3
      How to use this information:
      a) Suppose DBA wants to delete all tables. He/she may soon face a lot of foreign key constraint errors. How to avoid it? Delete all tables from nodeLevel n, then delete all tables from nodeLevel n - 1, etc.
      b) Suppose DBA wants to bcp/bulk insert all/some the tables of a database. Soon, he/she may face a lot of foreign key constraint errors. How to avoid it? bcp/bulk insert all tables from nodeLevel 1, then all tables from nodeLevel 2, etc.
 
   2. List of relationships
 
   3. List of recursive relationships
      Recursive relationships: are the ones where one child table can achieve a parent table through another table(s).
      Example: table A relates to table B one to many; table B relates to table C one to many. table C can achieve table A through table B, so there is an recursive relationship.
 
   4. List of doubtful relationships
      Doubtful relationships: child table may achieve (direct or recursively) a parent table through only one way. If that does not happen, there are doubtful relationships between child and parent table. When a doubtful relationship exists it is hard to keep ACID rules on the tables involved in the relationship
      Example: table A relates to table B one to many; table B relates to table C one to many; table A relates to table C one to many. table C can achieve table A two ways. First, table C relating to table B, then table B relating to table A and second, table C relating to table A. How can I assure both ways I will get same record from table A? Relationships are redundant and ACID rules are hard to assure.
      How to use this information: Analyze the output and exclude the ones which are assured to be redundant
 
   5. List of circular references
      Circular references: When one table eventually depends on itself
      Example: table A relates to table B one to many; table B relates to table C one to many; table C relates to table A one to many.
      How to use this information: Analyze the output and exclude the relationship(s) which is/are causing circular reference
 
*/
 
/*************************************************************************
 * Drops procedure if it already exists                                  *
 *************************************************************************/
IF EXISTS(
          SELECT *
          FROM dbo.sysobjects
          WHERE id = OBJECT_ID(N'[dbo].[ForeignkeysAnalyze]') AND
                1 = OBJECTPROPERTY(id, N'IsProcedure')
         )
BEGIN
    DROP PROCEDURE [dbo].[ForeignkeysAnalyze]
END
GO
 
/*************************************************************************
 * Creates procedure                                                     *
 *************************************************************************/
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
CREATE PROCEDURE [dbo].[ForeignkeysAnalyze]
AS
BEGIN
    /*************************************************************************
     * Sets NOCOUNT ON                                                       *
     *************************************************************************/
    SET NOCOUNT ON
 
    /*************************************************************************
     * Selects table names                                                   *
     *************************************************************************/
    SELECT dbo.sysobjects.name, 1 AS treeLevel
    INTO #tables
    FROM dbo.sysobjects
    WHERE dbo.sysobjects.type = 'U' AND
          dbo.sysobjects.name NOT LIKE 'dt_%'
    ORDER BY dbo.sysobjects.name
 
    /*************************************************************************
     * Selects relations                                                     *
     *************************************************************************/
    SELECT sysobjectsParent.name AS parentTable,
           sysobjectsChild.name AS childTable
    INTO #relations
    FROM dbo.sysforeignkeys
      INNER JOIN
         dbo.sysobjects AS sysobjectsChild
         ON dbo.sysforeignkeys.fkeyid = sysobjectsChild.id
      INNER JOIN
         dbo.sysobjects AS sysobjectsParent
         ON dbo.sysforeignkeys.rkeyid = sysobjectsParent.id
    GROUP BY sysobjectsParent.name,
             sysobjectsChild.name
    ORDER BY sysobjectsParent.name,
             sysobjectsChild.name
 
    /*************************************************************************
     * Creates and fulfills recursive relations                              *
     *************************************************************************/
    DECLARE @Step AS smallint
    SET @Step = 1
 
    SELECT #relations.parentTable,
           #relations.childTable,
           CAST('\' + #relations.parentTable + '\' + #relations.childTable + '\' AS varchar(1024)) AS Path,
           #relations.childTable AS rightOfParent,
           #relations.parentTable AS leftOfChild,
           @Step AS Step
    INTO #relationsRecursive
    FROM #tables
      INNER JOIN
         #relations
         ON #tables.name = #relations.parentTable
    ORDER BY #tables.treeLevel,
             #tables.name
 
    WHILE EXISTS(
                 SELECT #relationsRecursive.parentTable
                 FROM #relationsRecursive
                   INNER JOIN
                      #relations
                      ON #relationsRecursive.childTable = #relations.parentTable
                 WHERE #relationsRecursive.Step = @Step AND
                       CHARINDEX('\' + #relations.childTable + '\', #relationsRecursive.Path) = 0
                )
    BEGIN
        INSERT INTO #relationsRecursive
        (parentTable,
         childTable,
         [Path],
         rightOfParent,
         leftOfChild,
         Step
        )
        SELECT #relationsRecursive.parentTable,
               #relations.childTable,
               #relationsRecursive.Path + #relations.childTable + '\',
               #relationsRecursive.rightOfParent,
               #relationsRecursive.childTable,
               @Step + 1
        FROM #relationsRecursive
          INNER JOIN
             #relations
             ON #relationsRecursive.childTable = #relations.parentTable
        WHERE #relationsRecursive.Step = @Step AND
              CHARINDEX('\' + #relations.childTable + '\', #relationsRecursive.Path) = 0
 
        SET @Step = @Step + 1
    END
 
    /*************************************************************************
     * Sets treeLevel field                                                  *
     *************************************************************************/
    WHILE EXISTS(
                 SELECT #tablesChild.treeLevel
                 FROM #tables AS #tablesChild
                   INNER JOIN
                      #relations AS #relationsChild
                      ON #tablesChild.name = #relationsChild.childTable
                   INNER JOIN
                      #tables AS #tablesParent
                      ON #relationsChild.parentTable = #tablesParent.name
                 WHERE #tablesChild.treeLevel < #tablesParent.treeLevel + 1 AND
                       NOT EXISTS(
                                  SELECT #relationsRecursive.parentTable
                                  FROM #relationsRecursive
                                  WHERE #relationsRecursive.childTable = #tablesParent.name AND
                                        #relationsRecursive.parentTable = #tablesChild.name
                                 )
                )
    BEGIN
        UPDATE #tablesChild
        SET #tablesChild.treeLevel = #tablesParent.treeLevel + 1
        FROM #tables AS #tablesChild
          INNER JOIN
             #relations AS #relationsChild
             ON #tablesChild.name = #relationsChild.childTable
          INNER JOIN
             #tables AS #tablesParent
             ON #relationsChild.parentTable = #tablesParent.name
        WHERE #tablesChild.treeLevel < #tablesParent.treeLevel + 1 AND
              NOT EXISTS(
                         SELECT #relationsRecursive.parentTable
                         FROM #relationsRecursive
                         WHERE #relationsRecursive.childTable = #tablesParent.name AND
                               #relationsRecursive.parentTable = #tablesChild.name
                        )
 
    END
 
    /*************************************************************************
     * Creates table #relationsDoubtful                                      *
     *************************************************************************/
    SELECT #relationsRecursive.parentTable,
           #relationsRecursive.childTable,
           COUNT(#relationsRecursive.childTable) AS Occurrences
    INTO #relationsDoubtful
    FROM #relationsRecursive
    WHERE (
           SELECT COUNT(#relationsRecursiveSQ.Path)
           FROM #relationsRecursive AS #relationsRecursiveSQ
           WHERE #relationsRecursiveSQ.childTable = #relationsRecursive.childTable AND
                 #relationsRecursiveSQ.parentTable = #relationsRecursive.parentTable AND
                 #relationsRecursiveSQ.rightOfParent = #relationsRecursive.rightOfParent
          ) = 1 AND
          (
           SELECT COUNT(#relationsRecursiveSQ.Path)
           FROM #relationsRecursive AS #relationsRecursiveSQ
           WHERE #relationsRecursiveSQ.childTable = #relationsRecursive.childTable AND
                 #relationsRecursiveSQ.parentTable = #relationsRecursive.parentTable AND
                 #relationsRecursiveSQ.leftOfChild = #relationsRecursive.leftOfChild
          ) = 1
    GROUP BY #relationsRecursive.parentTable,
             #relationsRecursive.childTable
    HAVING COUNT(#relationsRecursive.childTable) > 1
    ORDER BY #relationsRecursive.parentTable,
             #relationsRecursive.childTable
 
    /*************************************************************************
     * Sets NOCOUNT OFF                                                      *
     *************************************************************************/
    SET NOCOUNT OFF
 
    /*************************************************************************
     * Selects tables name (with treeLevel included)                         *
     *************************************************************************/
    SELECT '#tables' AS Source,
           #tables.name,
           #tables.treeLevel
    FROM #tables
    ORDER BY #tables.treeLevel,
             #tables.name
 
    /*************************************************************************
     * Selects relations                                                     *
     *************************************************************************/
    SELECT '#relations' AS Source,
           #relations.*
    FROM #relations
    ORDER BY parentTable,
             childTable
 
    /*************************************************************************
     * Selects recursive relations                                           *
     *************************************************************************/
    SELECT '#relationsRecursive' AS Source,
           #relationsRecursive.*
    FROM #relationsRecursive
    ORDER BY parentTable,
             Path
 
    /*************************************************************************
     * Selects doubtful relations                                            *
     *************************************************************************/
    SELECT '#relationsDoubtful' AS Source,
           #relationsDoubtful.parentTable,
           #relationsDoubtful.childTable,
           #relationsRecursive.Path
    FROM #relationsDoubtful
      INNER JOIN
         #relationsRecursive
         ON #relationsDoubtful.childTable = #relationsRecursive.childTable AND
            #relationsDoubtful.parentTable = #relationsRecursive.parentTable
    ORDER BY #relationsDoubtful.childTable,
             #relationsRecursive.parentTable,
             #relationsRecursive.Path
 
    /*************************************************************************
     * Selects circular relations                                            *
     *************************************************************************/
    SELECT '#relationsCircular' AS Source,
           #relationsRecursive.parentTable,
           #relationsRecursive.childTable,
           #relationsRecursive.Path
    FROM #relationsRecursive
    WHERE EXISTS(
                 SELECT #relationsRecursiveSQ.parentTable
                 FROM #relationsRecursive AS #relationsRecursiveSQ
                 WHERE #relationsRecursiveSQ.parentTable = #relationsRecursive.childTable AND
                       #relationsRecursiveSQ.childTable = #relationsRecursive.ParentTable
                )
    ORDER BY #relationsRecursive.childTable,
             #relationsRecursive.parentTable,
             #relationsRecursive.Path
 
    /*************************************************************************
     * Finishes procedure                                                    *
     *************************************************************************/
    RETURN
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
EXECUTE [dbo].[ForeignkeysAnalyze]
GO
 
/*
dbo.ForeignkeysAnalyze.storedprocedure.sql dbo.ForeignkeysAnalyze.storedprocedure.sql
*/ 
