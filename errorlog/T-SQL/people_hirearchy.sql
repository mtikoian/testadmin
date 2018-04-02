drop table #people;

CREATE TABLE #People
    (PersonID int, Name varchar(20), ParentID int, QuestNodeUID INT)
;
    
INSERT INTO #People
    (personID, Name, ParentID)
VALUES
    (1001, 'Jack', 0),
    (1002, 'Damon', 1001),
    (1003, 'Tim', 1001),
    (1004, 'Nicole', 1001),
    (1005, 'Josh', 1002),
    (1006, 'Cooper', 1003),
    (1007, 'Seth', 1004)
;
DECLARE @CurrentLevel INT;
    SET @CurrentLevel = 1;
    drop table #Hierarchy;
--===== Create the Hierarchy table
 CREATE TABLE #Hierarchy
        (
        QuestTreeUID INT PRIMARY KEY,
        ParentUID INT,
        Level INT,
        Hierarchy VARCHAR(8000),
       -- QuestNodeUID INT
        );

--===== Seed the Hierarchy table with the top level
 INSERT INTO #Hierarchy
        (QuestTreeUID,ParentUID,Level,Hierarchy
        --,QuestNodeUID
        )
 SELECT personID,
        ParentID, 
        1 AS Level, 
        STR(personID,7)+' ' AS Hierarchy
      --  ParentID
   FROM #people
  WHERE ParentID =1001;
  
  --===== Determine the rest of the hierarchy
  WHILE @@ROWCOUNT > 0 
  BEGIN
            SET @CurrentLevel = @CurrentLevel + 1 --Started at 0
        
         INSERT INTO #Hierarchy
                (QuestTreeUID,ParentUID,Level,Hierarchy)
         SELECT p.personID,
                p.ParentID, 
                @CurrentLevel AS Level, 
                h.Hierarchy + STR(p.personID,7)+' ' AS Hierarchy
               -- p.QuestNodeUID
           FROM #people p 
          INNER JOIN #Hierarchy h
             ON p.ParentID = h.QuestTreeUID
            AND h.Level = @CurrentLevel - 1
    END;

--===== Produce the hierarchical report
 SELECT p.personID,p.ParentID,REPLICATE('-----',h.Level)+SPACE(SIGN(h.Level)) 
   FROM #people p,
        #Hierarchy h
  WHERE NOT (h.Level = 1 ) --Skips out of line entries
    AND p.personID = h.QuestTreeUID
  ORDER BY h.Hierarchy;

select * from #hierarchy;