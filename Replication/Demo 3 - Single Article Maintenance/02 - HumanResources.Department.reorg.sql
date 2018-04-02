use AdventureWorks2014;
go

-- select * from HumanResources.Department;

alter table HumanResources.Department
	drop constraint DF_Department_ModifiedDate;
go

drop index AK_Department_Name on HumanResources.Department;
go

alter table HumanResources.EmployeeDepartmentHistory
	drop constraint FK_EmployeeDepartmentHistory_Department_DepartmentID;
go

sp_rename 'HumanResources.PK_Department_DepartmentID', 'BACKUPPK_Department_DepartmentID', 'OBJECT'; 
go

create table HumanResources.Tmp_Department
(
    DepartmentID                       smallint identity (1, 1) not null,
	Name                               dbo.Name not null,
	GroupName                          dbo.Name not null,
	IncludeInLayoffs                   bit not null,       -- New column being added
	ModifiedDate                       datetime not null
    constraint PK_Department_DepartmentID primary key clustered 
	(
	    DepartmentID
	) 
    with
    ( 
        statistics_norecompute = off, 
        ignore_dup_key = off, 
        allow_row_locks = on, 
        allow_page_locks = on
    ) on [Primary]
)  on [Primary];
go

set identity_insert HumanResources.Tmp_Department on;
go
insert into HumanResources.Tmp_Department (DepartmentID, Name, GroupName, IncludeInLayoffs, ModifiedDate)
    select DepartmentID, Name, GroupName, 1, ModifiedDate from HumanResources.Department with (holdlock tablockx);
go
set identity_insert HumanResources.Tmp_Department off;
go


sp_rename 'HumanResources.Department', 'BACKUPDepartment', 'OBJECT'; 
go
sp_rename 'HumanResources.Tmp_Department', 'Department', 'OBJECT'; 
go


alter table HumanResources.Department add constraint
	DF_Department_ModifiedDate default (getdate()) for ModifiedDate
go


create unique nonclustered index AK_Department_Name on HumanResources.Department
(
	Name
) 
with
( 
    statistics_norecompute = off, 
    ignore_dup_key = off, 
    allow_row_locks = on, 
    allow_page_locks = on
) on [Primary];
go

alter table HumanResources.EmployeeDepartmentHistory add constraint
	FK_EmployeeDepartmentHistory_Department_DepartmentID foreign key
	(
	    DepartmentID
	) 
    references HumanResources.Department
	(
	    DepartmentID
	);
go

