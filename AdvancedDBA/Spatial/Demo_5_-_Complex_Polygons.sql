Use SpatialStuff
go

select * from timezones where TZID = 'America/Chicago'
go

--make into 1 COMPLEX polygon
SELECT Geography::UnionAggregate(geog) from timezones where TZID = 'America/Chicago'
go

--what can I do with this?
SELECT Geography::UnionAggregate(geog).STArea() from timezones where TZID = 'America/Chicago' --area in square meters.

0.0000003861 square miles in a square meter

SELECT Geography::UnionAggregate(geog).STArea() * 0.0000003861 from timezones where TZID = 'America/Chicago'

--1138128.4916098

--whole US is about 3.8 million square miles, so that seems right!


