
					AND NOT EXISTS (  -- not in
				SELECT dg.instr_id
				FROM dbo.DW_ISSUE_DG dg
				WHERE dg.INSTR_ID = qi.instr_id
				)
/* IS NOT NULL in the subquery */
SELECT C.color
FROM Colors AS C
WHERE C.color NOT IN (SELECT P.color
                      FROM Products AS P
                      WHERE P.color IS NOT NULL);
 
/* EXCEPT */
SELECT color
FROM Colors
EXCEPT
SELECT color
FROM Products;
 
/* LEFT OUTER JOIN */
SELECT C.color
FROM Colors AS C
LEFT OUTER JOIN Products AS P
  ON C.color = P.color
WHERE P.color IS NULL;
				
				
				
				
/*Dynamic SQL*/ 
--Always @sql_txt1 should be varchar(max)
--EXECUTE sp_executesql @sql_txt1


--Predicate evaluation order
FROM
WHERE
GROUP BY
HAVING
SELECT