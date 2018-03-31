---Let's go back to our Circular Arcs example
--What if I want to see the Intersection and Union Methods?

DECLARE @g geometry =
'CURVEPOLYGON
(
CIRCULARSTRING(0 4, 5 2, 10 4, 5 6, 0 4), 
CIRCULARSTRING(1 4, 3 3, 5 4, 3 5, 1 4),
CIRCULARSTRING(6 5, 7 4, 8 5, 7 6, 6 5),
CIRCULARSTRING(6 3, 5 1, 6 0, 7 1, 6 3)
)'; 

select @g

-----

declare @rectangle geometry = 
'POLYGON
((3 7, 3 0, 6 0, 6 7, 3 7))';

select @rectangle

---------------

DECLARE @g geometry =
'CURVEPOLYGON
(
CIRCULARSTRING(0 4, 5 2, 10 4, 5 6, 0 4), 
CIRCULARSTRING(1 4, 3 3, 5 4, 3 5, 1 4),
CIRCULARSTRING(6 5, 7 4, 8 5, 7 6, 6 5),
CIRCULARSTRING(6 3, 5 1, 6 0, 7 1, 6 3)
)'; 


declare @r geometry = 
'POLYGON
((3 7, 3 0, 6 0, 6 7, 3 7))';

select @g
UNION ALL
select @r

SET @g = @g.MakeValid();
SET @r = @r.MakeValid();

select @r.STIntersection(@g)
select @r.STUnion(@g)







