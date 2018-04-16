
-- Code needed to convert datetimeoffset to date, time and integral offset value

declare @Now    datetimeoffset

set @Now = sysdatetimeoffset()

select  cast(@now as date),
        cast(@now as time(3)),
        datepart(tz, @Now)