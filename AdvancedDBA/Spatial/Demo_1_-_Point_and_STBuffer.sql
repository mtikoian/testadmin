------SCRIPT1
declare @latitude float, @longitude float;
set @latitude = 36.2114457;
set @longitude = -86.6966879;

Declare @location geography = geography::Point(@latitude, @longitude, 4326);

select @location

--so tiny!
------SCRIPT2
declare @latitude float, @longitude float;
set @latitude = 36.2114457;
set @longitude = -86.6966879;

Declare @location geography = geography::Point(@latitude, @longitude, 4326);

select @location.STBuffer(10);
------SCRIPT3
--drawing a line between 2 points and making it a single object

declare @point1 geometry, @point2 geometry, @line geometry

set @point1 = geometry::Point(1,1,0)
set @point2 = geometry::Point(100,1,0)
select @point1.STBuffer(1)
UNION ALL
select @point2.STBuffer(1)

----------------
------SCRIPT4
declare @line geometry = 'LINESTRING(1 1, 100 1)'; 
select @line

--alternative syntax
declare @line geometry
SET @line = geometry::STGeomFromText('LINESTRING(1 1, 100 1)',0)
select @line

--adding a buffer
declare @line geometry = 'LINESTRING(1 1, 100 1)'; 
select @line.STBuffer(1)