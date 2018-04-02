use AdventureWorks2014;
go



select 'sp_addarticle @publication = ''AdventureWorks2014'', @article = ''' + s.name + '.' + o.name +
    ''', @source_owner = ''' + s.name + 
    ''', @source_object = ''' + o.name + 
    ''', @type = ''logbased'', @description = '', @creation_script = '', @pre_creation_cmd = ''drop'', @schema_option = 0x00000000000000F3, @identityrangemanagementoption = ''none'', @destination_table = ''' + o.name + 
    ''', @destination_owner = ''' + s.name + 
    ''', @status = 16, @vertical_partition = ''false'', ' + 
    '@ins_cmd = ''CALL ' + s.name + '.zRepl_ins_' + o.name + 
    ''', @del_cmd = ''CALL ' + s.name + '.zRepl_del_' + o.name + 
    ''', @upd_cmd = ''MCALL ' + s.name + '.zRepl_upd_' + o.name
from
        sys.schemas s
    inner join
        sys.objects o
            on s.schema_id = o.schema_id
where o.type = 'U'
order by s.name + '.' + o.name;

