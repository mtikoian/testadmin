set nocount on
go

-- This script generates test data

declare @t1 table (
    c0  int identity(1,1) primary key clustered, 
    c1  varchar(10)
)

declare @t2 table (
    c0  int identity(1,1) primary key clustered,
    c1  varchar(10)
)

declare @Result table (
    c0  int identity(1,1) primary key clustered,
    c1  varchar(10)
)    

insert into @t1 (c1)
select  'V1' union
select  'V2' union
select  'V3' union
select  'V4' union
select  'V5' union
select  'V6' union
select  'V7' union
select  'V8' union
select  'V9' union
select  'V0'

insert into @t2 (c1)
select  '|' union
select  '|' union
select  '|' union
select  '|' union
select  '|' union
select  '|' union
select  '|' union
select  '|' 

;with td1 (vc1) as 
(
    select  '1' + t1.c1 + t2.c1
    from @t1 t1 
    cross join @t2 t2
),
td2 (vc2) as 
(
    select  '2' + t1.c1 + t2.c1
    from @t1 t1
    cross join @t2 t2    
)
insert into @Result
select  td1.vc1
from @t1 t1
    cross join @t2 t2
    cross join td1 td1
    cross join td2 td2
    
-- End of data generation    
declare @Str    varchar(8000)
set @Str = ''
select  @Str = @Str + c1 from @Result

select datalength(@Str)  
    
    