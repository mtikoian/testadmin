

alter table CHECKCALL add truckpoint GEOGRAPHY


update CHECKCALL set truckpoint = GEOGRAPHY::Point(ckc_latseconds/3600.0,-ckc_longseconds/3600.0, 4326) 
where ckc_latseconds is not null and ckc_longseconds is not null
and ckc_latseconds/3600.0 between -90 and 90 and -ckc_longseconds/3600.0 between -180 and 180

create spatial index ix_checkcall_truckpoint on checkcall(truckpoint) 

--drop view v_latest_truck_position

create view dbo.v_latest_truck_position WITH SCHEMABINDING
as
select * from 
(
SELECT ckc_tractor,ckc_latseconds/3600.0 as latitude, -ckc_longseconds/3600.0 as longitude, 
ROW_NUMBER()OVER(PARTITION BY ckc_tractor ORDER BY ckc_date DESC)rn
FROM dbo.checkcall  
where ckc_latseconds is not null and ckc_longseconds is not null
and ckc_latseconds/3600.0 between -90 and 90 and -ckc_longseconds/3600.0 between -180 and 180
)X where rn = 1

drop table latest_truck_positions
create table latest_truck_positions (ckc_tractor char(8) not null, latitude float, longitude float)

alter table latest_truck_positions add constraint clix_latest_truck_positions primary key clustered (ckc_tractor)

insert latest_truck_positions
select ckc_tractor, latitude, longitude from 
(
SELECT ckc_tractor,ckc_latseconds/3600.0 as latitude, -ckc_longseconds/3600.0 as longitude, 
ROW_NUMBER()OVER(PARTITION BY ckc_tractor ORDER BY ckc_date DESC)rn
FROM dbo.checkcall  
where ckc_latseconds is not null and ckc_longseconds is not null
and ckc_latseconds/3600.0 between -90 and 90 and -ckc_longseconds/3600.0 between -180 and 180
)X where rn = 1

alter table latest_truck_positions add truckpoint GEOGRAPHY

update latest_truck_positions set truckpoint = GEOGRAPHY::Point(latitude,longitude, 4326) 

create spatial index ix_checkcall_truckpoint on latest_truck_positions(truckpoint) 



select cty_code, cty_name, cty_state, cty_latitude, cty_longitude, citypoint 
from city where cty_name = 'beachwood' and cty_state = 'OH'
--30625 is Beachwood, OH

--Select trucks within a 300 mile radius of Beachwood, OH
DECLARE  @distance FLOAT = (300 * 1609.344)--meters to miles
DECLARE @beachwood GEOGRAPHY = (SELECT citypoint from city where cty_name = 'beachwood' and cty_state = 'OH')
--compares citypoint of city table contents to the citypoint of Beachwood, OH specifically.
SELECT ckc_tractor, truckpoint, truckpoint.STDistance(@beachwood)/1609.344 AS dist_in_miles
from latest_truck_positions where truckpoint.STDistance(@beachwood)  <= @distance
order by truckpoint.STDistance(@beachwood)


--what's the closest city and state to where each of these trucks are?
DECLARE  @distance FLOAT = (300 * 1609.344)--meters to miles
DECLARE @beachwood GEOGRAPHY = (SELECT citypoint from city where cty_name = 'beachwood' and cty_state = 'OH')
--compares citypoint of city table contents to the citypoint of Beachwood, OH specifically.
;WITH trucklocations as 
(
SELECT ckc_tractor, truckpoint, truckpoint.STDistance(@beachwood)/1609.344 AS dist_in_miles
from latest_truck_positions where truckpoint.STDistance(@beachwood)  <= @distance
)
SELECT * from 
(
SELECT ckc_tractor, truckpoint, dist_in_miles, cty_code, cty_name, cty_state,
ROW_NUMBER()OVER(PARTITION BY ckc_tractor ORDER BY citypoint.STDistance(truckpoint) ASC) rn
FROM dbo.city, trucklocations
where citypoint.STDistance(truckpoint) < 100 * 1609.344 --had to put a limit in miles
)X where rn = 1
order by dist_in_miles

