
declare @last_run_date      datetime
declare @prior_run_date1    datetime
declare @prior_run_date2    datetime

;with Dates (RowNum, DateValue) as
(
    select  top 3
            row_number() over(order by Calendar_Date desc),
            Calendar_Date
    from Dimension_Date
    where Calendar_Date <= '2011-08-30'
    --order by Calendar_Date desc
),
Latest (RowNum, DateValue) as
(
    select  1,
            DateValue
    from Dates
    where RowNum = 1
),
Middle (RowNum, DateValue) as
(
    select  1,
            DateValue
    from Dates
    where RowNum = 2
),
Earliest (RowNum, DateValue) as
(
    select  1,
            DateValue
    from Dates
    where RowNum = 3
)
select  @last_run_date = l.DateValue,
        @prior_run_date1 = m.DateValue,
        @prior_run_date2 = e.DateValue  
from Latest l
    inner join Middle m on m.RowNum = l.RowNum
    inner join Earliest e on e.RowNum = l.RowNum
    
select  @last_run_date,
        @prior_run_date1,
        @prior_run_date2    