declare @PTable table (
    C1  varchar(1000)
)

declare @PString    varchar(1000)
declare @PDelimiter char(1)

-- set @PString = 'qqqqq,aaaa,sss,ddddd,hhhhh,tttt,kkkk,cccccc,dddddd,sssss' ;
insert into @PTable
select  'qqqqq,aaaa,sss,ddddd,hhhhh,tttt,kkkk,cccccc,dddddd,sssss' union
select  'zzzzz,aaaa,sss,ddddd,hhhhh,tttt,kkkk,cccccc,dddddd,sssss'

set @PDelimiter = ','

;with E1(N) as
    (
        select 1 union all select 1 union all select 1 union all
        select 1 union all select 1 union all select 1 union all
        select 1 union all select 1 union all select 1 union all select 1
    ),                          --10E+1 or 10 rows
    E2(N) as
    (
        select 1
        from E1 a, E1 b -- cross join yields 100 rows
    ),
    E4(N) as
    (
        select 1
        from E2 a, E2 b -- another cross join yields 10,000 rows
    ),
    cteTally(N) as
    (   --==== This provides the "zero base" and limits the number of rows right up front
        -- for both a performance gain and prevention of accidental "overruns"
        select 0
        union all
        select top (datalength(isnull(p.C1,1))) row_number() over (order by (select null))
        from E4 e4
            cross join @PTable p
    ),
    cteStart(N1) as
    (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
        select t.N + 1
        from cteTally t
            cross join @PTable p
        where (substring(p.C1, t.N, 1) = @pDelimiter or t.N = 0)
    )
    --select  distinct --ItemNumber = row_number() over(order by s.N1),
    --        Item       = substring(p.C1, s.N1, isnull(nullif(charindex(@pDelimiter, p.C1,s.N1), 0) - s.N1, 8000))
    --from cteStart s 
    --    cross join @PTable p;
    select * from cteTally