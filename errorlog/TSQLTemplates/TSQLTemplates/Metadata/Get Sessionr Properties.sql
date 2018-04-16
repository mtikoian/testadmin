


    declare @props table (
        propertyname sysname primary key
    )

    insert into @props(propertyname)
    select 'ANSI_NULLS'
    union all
    select 'ANSI_PADDING'
    union all
    select 'ANSI_WARNINGS'
    union all
    select 'ARITHABORT'
    union all
    select 'CONCAT_NULL_YIELDS_ NULL'
    union all
    select 'NUMERIC_ROUNDABORT'
    union all
    select 'QUOTED_IDENTIFIER'
     
    select  propertyname, 
            sessionproperty(propertyname) 
    from @props
                