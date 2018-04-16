
--====================================================================================================
--DDL Generator 
--====================================================================================================
--Script created by Ryan Foote.
set nocount on 

declare @Generate table (
	ColumnName		char(35)
	,DataType		char(30)
	,Nullability	varchar(400)
)

declare @FinalTable table (
	CreateStatement varchar(400)
)

declare @tblPrimaryKey table (
	PrimaryKeyID		int identity(1,1)
	,ColumnName			varchar(500) null
	,IndexDefinition	varchar(500) null
)

declare @PrimaryKey	varchar(50)
declare @TableName	varchar(100)

set @TableName = 'dbo.Daily_Login' --<<Enter the table name here

if not exists(
	select * 
	from sysobjects 
	where id = object_id(@TableName)
	  and objectproperty(ID, N'IsUserTable') = 1
	  ) 
begin
	print 'Table Name ' + @TableName + ' is not a valid table'
	goto KickOut
end
else if exists(
		select * 
		from sysobjects where id = object_id(@TableName)
		 and objectproperty(ID, N'IsUserTable') = 1
			  )
begin 
	insert into @Generate (
			ColumnName,
			DataType,
			Nullability
	)
	select	case 
				when syscolumns.colid = 1 then ' '
				else ',' 
			end + left(syscolumns.Name , 40),
			left(systypes.Name + case 
									when systypes.xusertype in (175, 11, 167, 165) --varchar, char
										then '(' + cast(syscolumns.length as varchar(10)) + ')'
									when systypes.xusertype in (239, 231) --nvarchar and nchar
										then '(' + cast(syscolumns.length/2 as varchar(10)) + ')'
									when systypes.xusertype in (106) --decimal
										then '(' + cast(syscolumns.xprec as varchar(10)) + ', ' + cast(sys.syscolumns.xscale as varchar(10)) + ')'
									else '' 
								 end, 20),
			case 
				when syscolumns.isnullable = 0 then 'NOT NULL'
				when syscolumns.isnullable = 1 then 'NULL'
			end + ' ' +
			case 
				when sys.default_constraints.name is not null
					then 'CONSTRAINT ' + ' ' + sys.default_constraints.name + ']' + ' ' + 'DEFAULT ' + sys.default_constraints.definition
				else ''
			end +
			case 
				when sys.identity_columns.name is not null
					then 'IDENTITY' + ' ' + '(' + cast(sys.identity_columns.seed_value as varchar(20)) + ', ' + cast(sys.identity_columns.increment_value as varchar(20)) + ')'
				else ''
			end
	from sys.syscolumns
		join sys.systypes on sys.syscolumns.xtype = sys.systypes.xtype
		left join sys.default_constraints on sys.default_constraints.parent_object_id = object_id(@TableName)
										 and sys.syscolumns.colid = sys.default_constraints.parent_column_id
		left join sys.identity_columns on sys.identity_columns.object_id = object_id(@TableName)
									  and sys.syscolumns.colid = sys.identity_columns.column_id
	where id = object_id(@TableName)
	  and sys.systypes.name <> 'sysname'
	order by sys.syscolumns.colid
end


select	@PrimaryKey = sys.indexes.name
from sys.indexes
	join sys.index_columns on sys.indexes.object_id = sys.index_columns.object_id
						  and sys.indexes.index_id = sys.index_columns.index_id
	join sys.syscolumns on sys.indexes.object_id = sys.syscolumns.id
					   and sys.index_columns.column_id = sys.syscolumns.colid
where sys.syscolumns.id = object_id(@TableName)
  and sys.indexes.is_primary_key = 1


insert into @tblPrimaryKey(
		ColumnName, 
		IndexDefinition
)
select	sys.syscolumns.name
		,sys.indexes.type_desc
from sys.indexes
	join sys.index_columns on sys.indexes.object_id = sys.index_columns.object_id
						  and sys.indexes.index_id = sys.index_columns.index_id
	join sys.syscolumns on sys.indexes.object_id = sys.syscolumns.id
					   and sys.index_columns.column_id = sys.syscolumns.colid
where sys.syscolumns.id = object_id(@TableName)
  and sys.indexes.is_primary_key = 1


insert into @FinalTable(CreateStatement)
values('if not exists(select * from sysobjects where id = object_id(''' + @TableName + ''')')

insert into @FinalTable(CreateStatement)
values (' and objectproperty(ID, N''IsUserTable'') = 1)')

insert into @FinalTable(CreateStatement)
values ('begin')

insert into @FinalTable(CreateStatement)
values ('create Table dbo.' + @TableName + ' (')

--insert into @FinalTable(CreateStatement)
--values( '(')

insert into @FinalTable(CreateStatement)
select char(9) + ColumnName + DataType + Nullability from @Generate 

insert into @FinalTable(CreateStatement)
values( ')')

if @PrimaryKey is null --table has no primary key defined
begin
goto statement
end

insert into @FinalTable(CreateStatement)
values('')

insert into @FinalTable(CreateStatement)
values('Alter table dbo.' + @TableName + '')

insert into @FinalTable(CreateStatement)
values('Add Constraint ' + @PrimaryKey + '')

insert into @FinalTable(
		CreateStatement
)
select 'Primary Key ' + IndexDefinition + ' (' + 
		max(case when PrimaryKeyID = 1 then ColumnName else ' ' end) +
		max(case when PrimaryKeyID = 2 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 3 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 4 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 5 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 6 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 7 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 8 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 9 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 10 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 11 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 12 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 13 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 14 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 15 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 16 then ', ' + ColumnName else '' end) +
		')' as PrimaryKey
from @tblPrimaryKey
group by IndexDefinition

statement:
insert into @FinalTable(CreateStatement)
values('End')

print '--Script generated on ' + convert(varchar(25), getdate(), 121)
select CreateStatement as [--CreateStatement] 
from @FinalTable

KickOut:
go


                