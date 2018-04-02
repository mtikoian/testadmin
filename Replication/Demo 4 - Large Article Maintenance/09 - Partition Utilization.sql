use AdventureWorks2014Replica;
go


-- Just to show that the replicated data is also partitioned.

select 
    ds2.name as filegroup,
    ps.name as partition_scheme,
    p.partition_number,
    coalesce(v.value, '') as range_boundary,
    -- In your environment, replace the three columns below with one column for each table you are partitioning.
    sum(case o.name when 'SalesOrderHeader' then p.rows else 0 end) as SalesOrderHeader,
    sum(case o.name when 'SalesOrderDetail' then p.rows else 0 end) as SalesOrderDetail,
    sum(case o.name when 'SalesOrderHeaderSalesReason' then p.rows else 0 end) as SalesOrderHeaderSalesReason
from
        sys.objects o
    inner join          
        sys.indexes i
            on o.object_id = i.object_id
           and i.is_primary_key = 1 
    inner join
        sys.partition_schemes ps
            on i.data_space_id = ps.data_space_id
    inner join
        sys.partition_functions pf
            on ps.function_id = pf.function_id
    inner join
        sys.destination_data_spaces dds
            on ps.data_space_id = dds.partition_scheme_id
    inner join 
        sys.data_spaces ds2
            on dds.data_space_id = ds2.data_space_id
    inner join 
        sys.partitions p
             on dds.destination_id = p.partition_number
            and p.object_id = i.object_id
            and p.index_id = i.index_id
    left outer join 
          sys.Partition_Range_Values v
               on pf.function_id = v.function_id
              and v.boundary_id = p.partition_number - pf.boundary_value_on_right 
group by
    ds2.name,
    ps.name,
    p.partition_number,
    v.value
order by p.partition_number;



   
