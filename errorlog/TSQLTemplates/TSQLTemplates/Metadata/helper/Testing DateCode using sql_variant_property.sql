
declare @x  datetime2;
declare @a  datetime2;
declare @z  datetime2;
declare @y  sql_variant;

set @x = dateadd(dd, 1, sysdatetime());
set @a = dateadd(dd, 2, sysdatetime());
--set @z = dateadd(day, 1, dateadd(day, 0, datediff(d, 0, @x)));
set @z = dateadd(ns, -100, cast(dateadd(day, 1, dateadd(day, 0, datediff(d, 0, @x))) as datetime2)); -- This one fails
--set @z = dateadd(ns, -100, @a); -- This one works
--set @z = dateadd(ns, -100, dateadd(day, 0, datediff(d, 0, @x))); -- This fails
--set @z = dateadd(day, 0, datediff(d, 0, @x));

select @z;

select  sql_variant_property(@x, 'BaseType'),
        sql_variant_property(dateadd(dd, 0, @x), 'BaseType')             