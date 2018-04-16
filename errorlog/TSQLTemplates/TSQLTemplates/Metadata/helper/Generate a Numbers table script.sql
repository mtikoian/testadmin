set nocount on 
go

/*
The point of this script is to serve as the basis for generating a tally
table of N numbers. The script can be modified to return any number of values
*/

begin try

    ;with E1(N) as
    (
        select 1 union all select 1 union all select 1 union all
        select 1 union all select 1 union all select 1 union all
        select 1 union all select 1 union all select 1 union all select 1
    ),                          --10E+1 or 10 rows
    E2(N) as
    (
        select  1
        from E1 a
            cross join E1 b -- cross join yields 100 rows
    ),
    E4(N) as
    (
        select  1
        from E2 a
            cross join E2 b -- another cross join yields 10,000 rows
    ),
    E5(N) as
    (
        select  1
        from E4 a
            cross join E2 b
    )  
    select  top 100 N,
            row_number() over(order by N)
    from E5              

end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch
