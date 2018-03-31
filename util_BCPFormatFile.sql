﻿create procedure dbo.util_BCPFormatFile
@header nvarchar(max)
,@delimiter nvarchar(6)= ','
,@table sysname= null
as
/*
————————————————————————————————————————————————————————————————————————————————
© 2000-09 • NightOwl Development • All rights reserved.
————————————————————————————————————————————————————————————————————————————————
Developer:Paul Hunter
Created :07/17/2009
Purpose :Build an non-xml format file from the "header" string of a file for
use by a BCP command. Handles problems associated with text-qualified
files such as CSV.

exec util_BCPFormatFile '"City","ST","ZIP","Country","Type","Pref","AC","FIPS","County","TZ","DST","Lat","Long","MSA","PMSA","Abbrev","MA","CBSA","Div","Population"'
,@delimiter= ','
,@table= 'dbo.zip_stg'

Sample:@header= '"DVD_Title","Studio",Released,"Status","Sound","Versions",Price,"Rating","Year","Genre","Aspect","UPC",DVD_ReleaseDate,ID,Timestamp,Updated'
@delimiter= ','
@table= 'dbo.test_table'--[optional] uses data from sys.columns for file length and position
otherwise it uses "column name" as length if table isn't 
found or column isn't matched

create table dbo.test_table
(DVD_Titlevarchar(128)
,Studiovarchar(30)
,Releaseddatetime
,Statusvarchar(10)
,Soundvarchar(10)
,Versionsvarchar(10)
,Pricemoney
,Ratingvarchar(10)
,Yearchar(4)
,Genrevarchar(10)
,Aspectvarchar(15)
,UPCvarchar(25)
,DVD_ReleaseDatedatetime
,IDint primary key
,Timestamptimestamp
,Updatedsmallint
)

Yields the result set for a format file:
————————————————————————————————————————————————————————————————————————————————
9.0
16
1 SQLCHAR00  "\""   0dummy_col       SQL_Latin1_General_CP1_CI_AS
2 SQLCHAR0128"\",\""1DVD_Title       SQL_Latin1_General_CP1_CI_AS
3 SQLCHAR030 "\","  2Studio          SQL_Latin1_General_CP1_CI_AS
4 SQLCHAR08  ",\""  3Released        ""
5 SQLCHAR010 "\",\""4Status          SQL_Latin1_General_CP1_CI_AS
6 SQLCHAR010 "\",\""5Sound           SQL_Latin1_General_CP1_CI_AS
7 SQLCHAR010 "\","  6Versions        SQL_Latin1_General_CP1_CI_AS
8 SQLCHAR08  ",\""  7Price           ""
9 SQLCHAR010 "\",\""8Rating          SQL_Latin1_General_CP1_CI_AS
10SQLCHAR04  "\",\""9Year            SQL_Latin1_General_CP1_CI_AS
11SQLCHAR010 "\",\""10  Genre           SQL_Latin1_General_CP1_CI_AS
12SQLCHAR015 "\",\""11  Aspect          SQL_Latin1_General_CP1_CI_AS
13SQLCHAR025 "\","  12  UPC             SQL_Latin1_General_CP1_CI_AS
14SQLCHAR08  ","    13  DVD_ReleaseDate ""
15SQLCHAR04  ","    14  ID              ""
16SQLCHAR08  ","    15  Timestamp       ""
17SQLCHAR02  "\r\n" 16  Updated         ""

History :
 DateDeveloperDescription
————————————————————————————————————————————————————————————————————————————
————————————————————————————————————————————————————————————————————————————————
*/


set nocount on;

declare

@addField bit
,@carryOver bit
,@column nvarchar(255)
,@field nvarchar(255)
,@fieldNum int
,@length varchar(5)
,@pos int
,@start int
,@startQuote bit
,@stop int
,@tableId int
,@termChar varchar(6)
,@terminator varchar(6)
,@version nvarchar(128)
--constants...
,@COLLATION nvarchar(35)
,@QUOTE char(1)
,@QUOTE_E char(2)
,@SQLCHAR char(7)

declare @format table
(rowId smallint identity primary key
,colName sysname not null
,terminator varchar(6) not null
,colOrder varchar(5) not null
,fileLength varchar(5) not null
);

--initialize variables
select @addField= 0
,@carryOver= 0
,@column = ''
,@fieldNum= 1
,@length= ''
,@startQuote= 0
,@tableId= object_id(@table)
,@termChar= case @delimiter when char(9) then '\t' else @delimiter end
,@terminator= ''
,@version= convert(nvarchar(128), serverproperty(N'ProductVersion'))
--constants...
,@COLLATION= convert(nvarchar(128), serverproperty(N'Collation'))
,@QUOTE= '"'
,@QUOTE_E= '\"'
,@SQLCHAR= 'SQLCHAR'

--get the SQL Engine version...
set @version = left(@version, charindex('.', @version) + 1);

while charindex(@delimiter, @header) > 0
begin
set @pos= charindex(@delimiter, @header);--find the next delimiter
set @field= left(@header, @pos - 1);--collect that value
set @header= substring(@header, @pos + 1, len(@header));--shorten the header by the field just removed...
set @addField =0;
set @carryOver=case len(@column)
when 0 then 0
else 1 end;

set @startQuote=case left(@field, 1) 
when @QUOTE then 1
else 0 end;

set @column=@column + replace(@field, @QUOTE, '') + ' ';--remove quotes

set @length=cast(len(@column) as varchar(5));--default length is the lenght from the "column"

if (@startQuote = 1 or @carryOver = 1)
begin
if right(@field, 1) = @QUOTE
begin
set @addField=1;
set @terminator =@QUOTE_E + @termChar
+case left(@header, 1)
when @QUOTE then @QUOTE_E
else '' end;
end;
end;
else
begin
set @addField=1;
set @terminator =@termChar
+case left(@header, 1)
when @QUOTE then @QUOTE_E
else '' end;
end;



if (@addField = 1)
begin
set @column = rtrim(@column);
if(@fieldNum = 1 and charindex(@QUOTE, @field) > 0)
begin
--add an "dummy column" if it's the first field and it starts with a quote
insert @format values('dummy_col', @QUOTE_E, 0, 0);
end;


--add the column to the database
insert @format values(@column, @terminator, @fieldNum, @length);
set @fieldNum= @fieldNum + 1;
set @terminator = '';
set @column= '';
end;
end;

--the part of the header is the last field...
set @column=replace(@header, @QUOTE, '');
set @length=cast(len(@column) as varchar(5));
set @terminator=case right(@header, 1)
when @QUOTE then @QUOTE_E
else '' end + '\r\n'


insert @format values(@column, @terminator, @fieldNum, @length)

--return the resulting format file definition...
select FileOrder
,FileType
,PrefixLength
,FileLength
,Terminator
,ColumnOrder
,ColumnName
,ColumnCollation
from(select 0 as type
,0 as rowId
,left(@version, 6)as FileOrder
,''as FileType
,''as PrefixLength
,''as FileLength
,''as Terminator
,''as ColumnOrder
,''as ColumnName
,''as ColumnCollation
union all
select 1 as type
,0 as rowId
,cast(@fieldNum as varchar(6))
,''as FileType
,''as PrefixLength
,''as FileLength
,''as Terminator
,''as ColumnOrder
,''as ColumnName
,''as ColumnCollation
union all
select 2 as type
,f.rowId
,cast(f.rowId as varchar(6))
,@SQLCHAR as FileType
,'0'as PrefixLength
,isnull(c.max_length, f.FileLength)
,'"' + isnull(Terminator, '') + '"'
,isnull(c.column_id, f.colOrder)
,isnull(c.name, f.colName)
,isnull(c.collation_name, @COLLATION)
from @format f
left outer join
(select cast(column_id as varchar(5))as column_id
,name
,cast(max_length as varchar(5))as max_length
,isnull(collation_name, '""')as collation_name
from sys.columns
where object_id = @tableId
)c on f.colName = c.name
)f
order by f.type, f.rowId;

return @@error;





