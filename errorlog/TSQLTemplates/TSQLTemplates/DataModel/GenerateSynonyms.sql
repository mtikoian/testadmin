
print '------------------------------------------------------------';
print 'Script file for procedure dbo.GenerateSynonyms';
print 'Start time is: ' + cast(getdate() as varchar(36)) ;
print 'SVN $Revision: 504 $';
print '';
if exists (
    select *
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'GenerateSynonyms'
      and ROUTINE_TYPE = 'Procedure'
        ) begin
    print 'Dropping procedure dbo.GenerateSynonyms'
    drop procedure dbo.GenerateSynonyms
end else begin
    print 'Procedure dbo.GenerateSynonyms does not exist, skipping drop'
end
go

print 'Creating procedure dbo.GenerateSynonyms';
go

create procedure dbo.GenerateSynonyms
   with
   execute as CALLER
as
set nocount on
/***
================================================================================
Name : GenerateSynonyms
Author : Patrick W. O'Brien - 08/16/2010
$Author: smclarnon $
$Date: 2012-09-12 08:11:57 -0400 (Wed, 12 Sep 2012) $
$Revision: 504 $
$URL: http://seisubvapp01/EnhancedClientReporting/Build/20120912_Full/SQLScripts/GenerateSynonyms.sql $ 

Description : Generates synonyms dynamically based on the contents of the table
              Table_Reference
===============================================================================
Parameters :
Name            |I/O|     Description
--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
Return Value: 0
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date      | Description
--------------------------------------------------------------------------------
SRM 201112??.1  Format modifications
                Changed from a cursor to a local table.
================================================================================
***/

-- Declarations
declare @sql_error      integer;
declare @db_nm          varchar (128);
declare @object_nm      varchar (128);
declare @synonym_nm     varchar (128);
declare @msg            varchar (256);
declare @Obj_Schema_nm  varchar (128);
declare @Syn_Schema_nm  varchar (128);
declare @CrLf           char(2);

-- Variables to dynamically query the Table_Reference
declare @sql    nvarchar (1000);

-- variables used for looping control
declare @MinId  int
declare @MaxId  int
declare @CurId  int

-- Local table to hold the table_reference data
declare @TableReference table (
    TableReferenceId    int identity(1,1) primary key clustered,
    DB_Nm               varchar(128),
    Object_Schema_nm    varchar(128),
    Object_Nm           varchar(128),
    Syn_Schema_Name     varchar(128),
    Synonym_Nm          varchar(128)
);

-- Cursor to retrieve the table_reference rows
begin try
    set @CrLf = char(13) + char(10);

    insert into @TableReference (
            DB_Nm,
            Object_Schema_nm,
            Object_Nm,
            Syn_Schema_Name,
            Synonym_Nm
    )
    select  DB_Nm,
            Object_Schema_nm,
            Object_Nm,
            Syn_Schema_Name,
            Synonym_Nm
    from dbo.Table_Reference
    order by DB_Nm,
            Object_Nm;
                
    -- **** Test **** 
    --select * from @TableReference
    -- goto Normal_Exit
    -- **** Test ****          

    set @MinId = (select min(TableReferenceId) from @TableReference);
    set @MaxId = (select max(TableReferenceId) from @TableReference);
    set @CurId = @MinId;

    while @CurId <= @MaxId begin

        select  @db_nm          = DB_Nm,
                @Obj_Schema_nm  = Object_Schema_nm,
                @object_nm      = Object_Nm,
                @Syn_Schema_nm  = Syn_Schema_Name,
                @synonym_nm     = Synonym_Nm
        from @TableReference
        where TableReferenceId = @CurId;

        -- If the synonym exists, drop it
        if object_id (@synonym_nm, 'SN') is not null begin

            select @sql = 'if exists (' + @CrLf +
                          '       select  *' + @CrLf +
                          '       from sys.Synonyms syn' + @CrLf +
                          '           inner join sys.Schemas sch on sch.Schema_Id = syn.Schema_Id ' + @CrLf +
                          'where sch.Name = ''' + @Syn_Schema_nm + '''' + @CrLf +
                          '  and syn.Name = ''' + @synonym_nm + '''' + @CrLf +
                          '           )' + @CrLf +
                          '   drop synonym ' + quotename(@Syn_Schema_nm) + '.' + quotename(@synonym_nm) + @CrLf
            --print @Sql
            exec(@sql)

            if (@@error <> 0) begin
                set @msg = 'Failed dropping synonym. SQL: ' + @sql
                raiserror (@msg, 16, 1);
            end
        end

        -- Create the synonym
        select @sql =   'create synonym ' + quotename(@Syn_Schema_nm) + '.' + quotename(@synonym_nm) + @CrLf +
                        ' for [' + @db_nm + '].' + @Obj_Schema_nm + '.[' + @object_nm + ']'
        --print @Sql
        exec(@sql)

        if (@@error <> 0) begin
            set @msg = 'Failed creating synonym. SQL: ' + @sql
            raiserror (@msg, 16, 1);
        end
        --break
        set @CurId = @CurId + 1
    end

end try
begin catch
    declare @errmsg varchar (100), @errsev int, @errstate int;

    select @sql_error = error_number (),
           @errmsg = error_message (),
           @errsev = error_severity (),
           @errstate = error_state ();

    raiserror (@errmsg, @errsev, @errstate);
end catch

      return @sql_error

go

exec sys.sp_addextendedproperty
		@name=N'SVN Revision',
		@value=N'$Rev: 504 $' ,
		@level0type=N'SCHEMA',
		@level0name=N'dbo',
		@level1type=N'PROCEDURE',
		@level1name=N'GenerateSynonyms'
go		

if exists (
    select *
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'GenerateSynonyms'
      and ROUTINE_TYPE = 'Procedure'
        ) begin
    print 'Procedure dbo.GenerateSynonyms, $Rev: 504 $ was created successfully'
end else begin
    print 'Procedure dbo.GenerateSynonyms does not exist, create failed'
end
print '';
print 'End time is: ' + cast(getdate() as varchar(36));
print 'End of script file for dbo.GenerateSynonyms'
print '----------------------------------------------------------------------'
go

