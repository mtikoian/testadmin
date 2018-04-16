with fk_cols as 
(
  select row_number() over(order by fkc.constraint_object_id) as row_num,
         pc.name as parent_name,
         cc.name as child_name,
         fkc.constraint_object_id
    from sys.foreign_key_columns fkc join sys.columns pc
           on fkc.parent_column_id = pc.column_id
              and fkc.parent_object_id = pc.object_id
         join sys.columns cc
           on fkc.parent_column_id = cc.column_id
              and fkc.parent_object_id = cc.object_id
)
select fk.name,
       po.name as parent_object_name,
       o.name as child_object_name,
       'insert into ' + po.name + char(10) +
       '(' + char(10) +
       (select case row_num when 1 then '' else ',' end + parent_name
                      from fk_cols
                     where constraint_object_id = fk.object_id
                    for xml path('')) + char(10) +
       ')' + char(10) +
       'select ' + (select case row_num when 1 then '' else ',' end + 'c.' + child_name
                      from fk_cols
                     where constraint_object_id = fk.object_id
                    for xml path('')) + char(10) +
       '  from ' + o.name + ' c left join ' + po.name + ' p ' + char(10) +
       '         on ' + (select case row_num when 1 then '' else ' and ' end + 'c.' + child_name + ' = p.' + parent_name + char(10)
                           from fk_cols
                          where constraint_object_id = fk.object_id
                         for xml path('')) +
       ' where p.' + (select child_name + ''
                        from fk_cols
                       where constraint_object_id = fk.object_id
                             and row_num = 1
                      for xml path('')) + ' is null' as sql_txt
  from sys.foreign_keys fk join sys.objects po
         on fk.referenced_object_id = po.object_id
       join sys.objects o
         on fk.parent_object_id = o.object_id;

-- example SQL to delete invalid child rows
with fk_cols as 
(
  select row_number() over(order by fkc.constraint_object_id) as row_num,
         pc.name as parent_name,
         cc.name as child_name,
         fkc.constraint_object_id
    from sys.foreign_key_columns fkc join sys.columns pc
           on fkc.parent_column_id = pc.column_id
              and fkc.parent_object_id = pc.object_id
         join sys.columns cc
           on fkc.parent_column_id = cc.column_id
              and fkc.parent_object_id = cc.object_id
)
select fk.name,
       po.name as parent_object_name,
       o.name as child_object_name,
       'delete c ' + char(10) +
       '  from ' + o.name + ' c left join ' + po.name + ' p ' + char(10) +
       '         on ' + (select case row_num when 1 then '' else ' and ' end + 'c.' + child_name + ' = p.' + parent_name + char(10)
                           from fk_cols
                          where constraint_object_id = fk.object_id
                         for xml path('')) +
       ' where p.' + (select child_name + ''
                        from fk_cols
                       where constraint_object_id = fk.object_id
                             and row_num = 1
                      for xml path('')) + ' is null' as sql_txt
  from sys.foreign_keys fk join sys.objects po
         on fk.referenced_object_id = po.object_id
       join sys.objects o
         on fk.parent_object_id = o.object_id;