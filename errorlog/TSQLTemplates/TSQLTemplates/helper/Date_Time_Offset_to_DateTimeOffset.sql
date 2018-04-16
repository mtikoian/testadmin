declare @t table (
    Add_Dt      date,
    Add_Tm      time,
    Add_Ofs     int,
    Update_Dt   date,
    Update_Tm   time,
    Update_Ofs  int
)

-- the line below is how you would concatenate date, time and offset into a datetimeoffset datatype.
select todatetimeoffset(cast(Update_Dt as varchar) + ' ' + cast(Update_Tm as varchar), Update_Ofs)
from @t

select todatetimeoffset(cast(Add_Dt as varchar) + ' ' + cast(Add_Tm as varchar), Add_Ofs )
from @t
