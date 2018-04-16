

declare @StartTime  datetimeoffset;
declare @EndTime    datetimeoffset;
declare @Ctr        int = 1;
declare @MaxLoop    int = 1000000;

set @StartTime = sysdatetimeoffset();

while @Ctr <= @MaxLoop begin

    set @Ctr = @Ctr

end;

set @EndTime = sysdatetimeoffset();