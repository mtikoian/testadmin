
exec sp_whoisactive @show_sleeping_spids = 2, @sort_order = '[tempdb_allocations]desc', @get_plans = 1

declare	@a		bigint
declare	@b		bigint
declare	@c		bigint
declare	@Start	int

set @a = power(1024, 3)
set @b = power(1024, 2)
set @c = 1024
set @Start = 23840               
                
select	(@Start * 8060) / @a as gig, 
		(@Start * 8060) / @b as meg,  
		(@Start * 8060) / @c as k             