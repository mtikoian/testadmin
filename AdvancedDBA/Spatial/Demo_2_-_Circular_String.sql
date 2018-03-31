DECLARE @g geography = 
'CIRCULARSTRING(
-122.358 47.653, 
-122.348 47.649, 
-122.348 47.658, 
-122.358 47.658, 
-122.358 47.653)'; 

select @g

------
--Showing a Buffered Line

DECLARE @g geography = 
'CIRCULARSTRING(
-122.358 47.653, 
-122.348 47.649, 
-122.348 47.658, 
-122.358 47.658, 
-122.358 47.653)'; 

select @g.STBuffer(20)


------
--Showing the Line and the Buffered Line together.

DECLARE @g geography = 
'CIRCULARSTRING(
-122.358 47.653, 
-122.348 47.649, 
-122.348 47.658, 
-122.358 47.658, 
-122.358 47.653)'; 
DECLARE @h geography = 
'CIRCULARSTRING(
-122.358 47.653, 
-122.348 47.649, 
-122.348 47.658, 
-122.358 47.658, 
-122.358 47.653)'; 

select @g.STBuffer(20)
UNION ALL
select @h


-----fill in that area instead of just the line.

DECLARE @g geography = 
'CURVEPOLYGON(CIRCULARSTRING(
-122.358 47.653, 
-122.348 47.649, 
-122.348 47.658, 
-122.358 47.658, 
-122.358 47.653))'; 

select @g