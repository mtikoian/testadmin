--Select cities within a 10 mile radius of Beachwood, OH
DECLARE @MilesAway INT = 10
DECLARE  @distance FLOAT = (@MilesAway * 1609.344)--meters to miles
DECLARE @beachwood GEOGRAPHY = (SELECT citypoint from city 
where cty_name = 'beachwood' and cty_state = 'OH')

--compares citypoint of city table contents to the citypoint of Beachwood, OH specifically.
SELECT cty_code, cty_name, cty_state, cty_latitude, 
cty_longitude,citypoint.STDistance(@beachwood) AS dist_in_meters
from city where citypoint.STDistance(@beachwood)  <= @distance


sp_helptext tmw_airdistance_fn