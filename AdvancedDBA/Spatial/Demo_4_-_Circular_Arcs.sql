DECLARE @g geometry =
'CURVEPOLYGON
(
CIRCULARSTRING(0 4, 4 0, 8 4, 4 8, 0 4), 
CIRCULARSTRING(2 4, 4 2, 6 4, 4 6, 2 4)
)'; 

select @g

-------------------
--mulitple objects

DECLARE @g geometry =
'CURVEPOLYGON
(
CIRCULARSTRING(0 4, 5 2, 10 4, 5 6, 0 4), 
CIRCULARSTRING(1 4, 3 3, 5 4, 3 5, 1 4),
CIRCULARSTRING(6 4, 7 3, 8 4, 7 5, 6 4)
)'; 

select @g

SELECT @g.STArea() AS Area; 

------
--what happens if I cross lines?

DECLARE @g geometry =
'CURVEPOLYGON
(
CIRCULARSTRING(0 4, 5 2, 10 4, 5 6, 0 4), 
CIRCULARSTRING(1 4, 3 3, 5 4, 3 5, 1 4),
CIRCULARSTRING(6 5, 7 4, 8 5, 7 6, 6 5),
CIRCULARSTRING(6 3, 5 1, 6 0, 7 1, 6 3)
)'; 

select @g





