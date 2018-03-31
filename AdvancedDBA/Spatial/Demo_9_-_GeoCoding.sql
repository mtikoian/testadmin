USE STAMPOLA
go

select top 2500 CD_ID, CD_CardholderStreetAddress, CD_CardholderTownCity, CD_CardholderPostCode from CustomerDetails
where CD_ID > 15

---------------
select top 2500 CD_ID, CD_CardholderStreetAddress, CD_CardholderTownCity, CD_CardholderPostCode, latitude, longitude from CustomerDetails
where CD_ID > 15

alter table CustomerDetails add geog geography

update CustomerDetails set geog = geography::Point(latitude, longitude, 4326) where latitude is not null and latitude <> 0

select geog from CustomerDetails where latitude is not null and latitude <> 0

