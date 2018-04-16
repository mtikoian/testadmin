

select cast(f.name  as varchar(255)) as foreign_key_name
    , r.keycnt
    , cast(c.name as  varchar(255)) as foreign_table
    , cast(fc.name as varchar(255)) as  foreign_column_1
    , cast(fc2.name as varchar(255)) as foreign_column_2
    ,  cast(p.name as varchar(255)) as primary_table
    , cast(rc.name as varchar(255))  as primary_column_1
    , cast(rc2.name as varchar(255)) as  primary_column_2
    from sysobjects f
    inner join sysobjects c on  f.parent_obj = c.id
    inner join sysreferences r on f.id =  r.constid
    inner join sysobjects p on r.rkeyid = p.id
    inner  join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
    inner  join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
    left join  syscolumns rc2 on r.rkeyid = rc2.id and r.rkey2 = rc.colid
    left join  syscolumns fc2 on r.fkeyid = fc2.id and r.fkey2 = fc.colid
    where f.type =  'F'
    and p.Name = 'Task'
 ORDER BY cast(p.name as varchar(255))            