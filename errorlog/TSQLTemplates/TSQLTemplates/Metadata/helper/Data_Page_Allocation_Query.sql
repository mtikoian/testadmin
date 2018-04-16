


--sp_help 'Advisor.Ticket'
select  object_name(Object_Id) as Name,
        Partition_ID,
        Partition_Number,
        Rows,
        Allocation_Unit_Id,
        Type_Desc,
        Total_Pages
from sys.Partitions p
    inner join sys.Allocation_Units u on p.Partition_Id = u.Container_Id
where object_id = object_id('Advisor.Ticket')
