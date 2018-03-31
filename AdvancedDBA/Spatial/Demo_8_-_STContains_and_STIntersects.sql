
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

SET @g = @g.MakeValid();
SET @r = @r.MakeValid();

declare @newshape geometry
set @newshape = @r.STIntersection(@g)

select @newshape

-------------------
set nocount on

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

SET @g = @g.MakeValid();
SET @r = @r.MakeValid();

declare @newshape geometry
set @newshape = @r.STIntersection(@g)

declare @smallsquare1 geometry = 
'POLYGON
((5 5, 5 4, 6 4, 6 5, 5 5))';

declare @smallsquare2 geometry = 
'POLYGON
((3 3, 3 2, 4 2, 4 3, 3 3))';


select @newshape
UNION ALL
select @smallsquare1
UNION ALL
select @smallsquare2


select 'NewShape Contains SmallSquare1', @newshape.STContains(@smallsquare1)
select 'NewShape Contains SmallSquare2', @newshape.STContains(@smallsquare2)
select 'NewShape Intersects SmallSquare1', @newshape.STIntersects(@smallsquare1)
select 'NewShape Intersects SmallSquare2', @newshape.STIntersects(@smallsquare2)

select 'SmallSquare1 Contains NewShape', @smallsquare1.STContains(@newshape)
select 'SmallSquare2 Contains NewShape', @smallsquare2.STContains(@newshape)
select 'SmallSquare1 Intersects NewShape', @smallsquare1.STIntersects(@newshape)
select 'SmallSquare2 Intersects NewShape', @smallsquare2.STIntersects(@newshape)

 /*    
NewShape Contains SmallSquare1 1
NewShape Contains SmallSquare2 0
NewShape Intersects SmallSquare1 1
NewShape Intersects SmallSquare2 1

SmallSquare1 Contains NewShape 0
SmallSquare2 Contains NewShape 0
SmallSquare1 Intersects NewShape 1
SmallSquare2 Intersects NewShape 1
*/



