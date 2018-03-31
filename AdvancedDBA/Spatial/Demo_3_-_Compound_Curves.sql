DECLARE @g geometry = 'COMPOUNDCURVE
(
CIRCULARSTRING(1 0, 0 2, 3 1), 
(3 1, 1 1), 
CIRCULARSTRING(1 1, 3 4, 4 1)
)';  


select @g
--------------------
--add a buffered line

DECLARE @g geometry = 'COMPOUNDCURVE
(
CIRCULARSTRING(1 0, 0 2, 3 1), 
(3 1, 1 1), 
CIRCULARSTRING(1 1, 3 4, 4 1)
)';  


select @g.STBuffer(1)
------
--break apart into circular strings and a linestring

DECLARE @f geometry = 'CIRCULARSTRING(1 0, 0 2, 3 1)';
DECLARE @g geometry = 'LINESTRING(3 1, 1 1)';
DECLARE @h geometry = 'CIRCULARSTRING(1 1, 3 4, 4 1)';

select @g
UNION ALL
select @f
UNION ALL
select @h

-------------
--add a buffer to just the linestring

DECLARE @f geometry = 'CIRCULARSTRING(1 0, 0 2, 3 1)';
DECLARE @g geometry = 'LINESTRING(3 1, 1 1)';
DECLARE @h geometry = 'CIRCULARSTRING(1 1, 3 4, 4 1)';

select @g.STBuffer(1)
UNION ALL
select @f
UNION ALL
select @h
---------------------
--make the compound curve longer and larger

DECLARE @g geometry = 'COMPOUNDCURVE
(
CIRCULARSTRING(100 0, 0 200, 300 100), 
(300 100, 100 100), 
CIRCULARSTRING(100 100, 300 400, 400 100)
)';  


select @g

----------------
--now add a buffer, and calculate the length

DECLARE @g geometry = 'COMPOUNDCURVE
(
CIRCULARSTRING(100 0, 0 200, 300 100), 
(300 100, 100 100), 
CIRCULARSTRING(100 100, 300 400, 400 100)
)';  


select @g.STBuffer(5)
select @g.STLength()
-----------------
