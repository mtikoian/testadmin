use AdventureWorks2014;
go

if  exists (select * from sys.objects where object_id = object_id('Sales.OnlineOrderSourceCode') and type in ('U'))
    drop table Sales.OnlineOrderSourceCode;
go

create table Sales.OnlineOrderSourceCode
(
    OnlineOrderSourceCodeId            int not null,
    Name                               varchar(100) not null,
    CreatedDate                        smalldatetime not null,
    CreatedBy                          varchar(50) not null,
    constraint PK_OnlineOrderSourceCode primary key clustered 
    (
	    OnlineOrderSourceCodeId ASC
    )
    with 
    (
        pad_index  = off, 
        statistics_norecompute  = off, 
        ignore_dup_key = off, 
        allow_row_locks  = on, 
        allow_page_locks  = on
    ) on [Primary]
) on [Primary];

go

insert into  Sales.OnlineOrderSourceCode values 
(-1, 'Brick and Mortar', getdate(), 'Providence SQL User Group'),
(1, 'AdventureWorks.com', getdate(),'Providence SQL User Group'),
(2, 'Amazon.com', getdate(),'Providence SQL User Group'),
(3, 'BikesDirect.com', getdate(),'Providence SQL User Group'); 
