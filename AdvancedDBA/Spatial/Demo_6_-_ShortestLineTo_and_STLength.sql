Use SpatialStuff
go

--Let's look at 2 timezones in the US.
SELECT Geography::UnionAggregate(geog) from timezones where TZID = 'America/Los_Angeles'
UNION ALL
SELECT Geography::UnionAggregate(geog) from timezones where TZID = 'America/Chicago'
go
--Draw the shortest Line between these two.

declare @Pacific geography, @Central geography
SELECT @Pacific = Geography::UnionAggregate(geog) from timezones where TZID = 'America/Los_Angeles'
SELECT @Central =  Geography::UnionAggregate(geog) from timezones where TZID = 'America/Chicago'
SELECT @Pacific.ShortestLineTo(@Central)

------------------

declare @Pacific geography, @Central geography
SELECT @Pacific = Geography::UnionAggregate(geog) from timezones where TZID = 'America/Los_Angeles'
SELECT @Central =  Geography::UnionAggregate(geog) from timezones where TZID = 'America/Chicago'

SELECT @Pacific
UNION ALL
Select @Central
UNION ALL
SELECT @Pacific.ShortestLineTo(@Central)

------------------


declare @Pacific geography, @Central geography
SELECT @Pacific = Geography::UnionAggregate(geog) from timezones where TZID = 'America/Los_Angeles'
SELECT @Central =  Geography::UnionAggregate(geog) from timezones where TZID = 'America/Chicago'

SELECT @Pacific.ShortestLineTo(@Central).STLength() * 0.000621371 --miles
SELECT @Pacific.ShortestLineTo(@Central).STAsText()




