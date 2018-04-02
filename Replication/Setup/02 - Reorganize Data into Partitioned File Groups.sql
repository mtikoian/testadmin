use master;
go

-- The below was taken from my Data Partitioning presentation at SQL Saturday Waltham. (Scripts 11 - 15.)
-- You can pick up that original material at http://www.sqlsaturday.com/viewsession.aspx?sat=142&sessionid=8111
-- This will take about 20 seconds.....

alter database AdventureWorks2014 add filegroup Trans2011Q2;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2011Q2', 
        filename = 'c:\data00\data\Trans2011Q2.ndf', 
        size = 1mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2011Q2;
go
           
alter database AdventureWorks2014 add filegroup Trans2011Q3;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2011Q3', 
        filename = 'c:\data00\data\Trans2011Q3.ndf', 
        size = 1mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2011Q3;
go        




alter database AdventureWorks2014 add filegroup Trans2011Q4;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2011Q4', 
        filename = 'c:\data00\data\Trans2011Q4.ndf', 
        size = 1mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2011Q4;
go
           
alter database AdventureWorks2014 add filegroup Trans2012Q1;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2012Q1', 
        filename = 'c:\data00\data\Trans2012Q1.ndf', 
        size = 1mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2012Q1;
go
           
alter database AdventureWorks2014 add filegroup Trans2012Q2;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2012Q2', 
        filename = 'c:\data00\data\Trans2012Q2.ndf', 
        size = 2mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2012Q2;
go
           
alter database AdventureWorks2014 add filegroup Trans2012Q3;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2012Q3', 
        filename = 'c:\data00\data\Trans2012Q3.ndf', 
        size = 2mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2012Q3;
go
        
    


alter database AdventureWorks2014 add filegroup Trans2012Q4;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2012Q4', 
        filename = 'c:\data00\data\Trans2012Q4.ndf', 
        size = 2mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2012Q4;
go
           
alter database AdventureWorks2014 add filegroup Trans2013Q1;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2013Q1', 
        filename = 'c:\data00\data\Trans2013Q1.ndf', 
        size = 2mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2013Q1;
go
           
alter database AdventureWorks2014 add filegroup Trans2013Q2;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2013Q2', 
        filename = 'c:\data00\data\Trans2013Q2.ndf', 
        size = 4mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2013Q2;
go
           
alter database AdventureWorks2014 add filegroup Trans2013Q3;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2013Q3', 
        filename = 'c:\data00\data\Trans2013Q3.ndf', 
        size = 5mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2013Q3;
go
        
    
    
    
alter database AdventureWorks2014 add filegroup Trans2013Q4;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2013Q4', 
        filename = 'c:\data00\data\Trans2013Q4.ndf', 
        size = 4mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2013Q4;
go
           
alter database AdventureWorks2014 add filegroup Trans2014Q1;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2014Q1', 
        filename = 'c:\data00\data\Trans2014Q1.ndf', 
        size = 5mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2014Q1;
go        

-- Typically - have the current partition over allocated.  (Especially in an OLTP scenario - you do not want to take file 
-- expansion events during the on-line day.)  We will shrink this out later.   
alter database AdventureWorks2014 add filegroup Trans2014Q2;
alter database AdventureWorks2014 add file
    (
        name = 'Trans2014Q2', 
        filename = 'c:\data00\data\Trans2014Q2.ndf', 
        size = 10mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup Trans2014Q2;
go            

alter database AdventureWorks2014 add filegroup TransFuture;
alter database AdventureWorks2014 add file
    (
        name = 'TransFuture', 
        filename = 'c:\data00\data\TransFuture.ndf', 
        size = 1mb, 
        maxsize = unlimited, 
        filegrowth = 500kb
    )
    to filegroup TransFuture;
go            

use AdventureWorks2014;
go


if  exists (select * from sys.partition_schemes where name = 'psQuarterly')
    drop partition scheme psQuarterly;
go

if  exists (select * from sys.partition_functions where name = 'pfQuarterly')
     drop partition function pfQuarterly;
go


-- Note:  One less entry in the function relative to the scheme.  The scheme maps the partitions.
-- The function defines the boarders between the partitions.

create partition function pfQuarterly(datetime) as range left for values 
(
                               '2011-06-30 23:59:59.997', '2011-09-30 23:59:59.997', '2011-12-31 23:59:59.997', 
    '2012-03-31 23:59:59.997', '2012-06-30 23:59:59.997', '2012-09-30 23:59:59.997', '2012-12-31 23:59:59.997', 
    '2013-03-31 23:59:59.997', '2013-06-30 23:59:59.997', '2013-09-30 23:59:59.997', '2013-12-31 23:59:59.997', 
    '2014-03-31 23:59:59.997', '2014-06-30 23:59:59.997' 
);
go

create partition scheme psQuarterly as partition pfQuarterly to 
(
                 Trans2011Q2, Trans2011Q3, Trans2011Q4, 
    Trans2012Q1, Trans2012Q2, Trans2012Q3, Trans2012Q4, 
    Trans2013Q1, Trans2013Q2, Trans2013Q3, Trans2013Q4,
    Trans2014Q1, Trans2014Q2, TransFuture  --<<-- The last entry - rage left - has no corresponding entry in the function
);

use AdventureWorks2014;
go


set quoted_identifier on;
set arithabort on;
set numeric_roundabort off;
set concat_null_yields_null on;
set ansi_nulls on;
set ansi_padding on;
set ansi_warnings on;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_SalesTerritory_TerritoryID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_ShipMethod_ShipMethodID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_SalesPerson_SalesPersonID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_Customer_CustomerID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_CurrencyRate_CurrencyRateID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_CreditCard_CreditCardID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_Address_BillToAddressID;
go

alter table Sales.SalesOrderHeader
	drop constraint FK_SalesOrderHeader_Address_ShipToAddressID;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_RevisionNumber;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_OrderDate;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_Status;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_OnlineOrderFlag;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_SubTotal;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_TaxAmt;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_Freight;
go

alter table Sales.SalesOrderHeader
	drop constrainT DF_SalesOrderHeader_rowguid;
go

alter table Sales.SalesOrderHeader
	drop constraint DF_SalesOrderHeader_ModifiedDate;
go


/*************************************************************************************/
/***                                                                               ***/
/***   Good Stuff Here.  I am                                                      ***/
/***   1)  Renaming the primary key of the old table so I can use that name        ***/
/***   2)  Adding the OrderDate column to the primary key on the new table         ***/
/***   3)  Allocating the new table on the partitioned file group                  ***/
/***                                                                               ***/
/*************************************************************************************/
     
sp_rename 'Sales.PK_SalesOrderHeader_SalesOrderID', 'BACKUPPK_SalesOrderHeader_SalesOrderID', 'OBJECT'; 
go



create table Sales.Tmp_SalesOrderHeader
(
	SalesOrderID                       int identity (1, 1) not null,
	RevisionNumber                     tinyint not null,
	OrderDate                          datetime not null,
	DueDate                            datetime not null,
	ShipDate                           datetime null,
	Status                             tinyint not null,
	OnlineOrderFlag                    dbo.Flag not null,
	SalesOrderNumber                   as (isnull(N'SO'+convert([nvarchar](23),[SalesOrderID],0),N'*** ERROR ***')),
	PurchaseOrderNumber                dbo.OrderNumber null,
	AccountNumber                      dbo.AccountNumber null,
	CustomerID                         int not null,
	SalesPersonID                      int null,
	TerritoryID                        int null,
	BillToAddressID                    int not null,
	ShipToAddressID                    int not null,
	ShipMethodID                       int not null,
	CreditCardID                       int null,
	CreditCardApprovalCode             varchar(15) null,
	CurrencyRateID                     int null,
	SubTotal                           money not null,
	TaxAmt                             money not null,
	Freight                            money not null,
	TotalDue                           as (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
	Comment                            nvarchar(128) null,
	rowguid                            uniqueidentifier not null rowguidcol,
	ModifiedDate                       datetime not null,
    constraint PK_SalesOrderHeader_SalesOrderID primary key clustered 
    (
        SalesOrderID asc,
        OrderDate
    ) 
    with 
    ( 
        pad_index  = on, 
        fillfactor = 95,      -- should be 100% - but leave 5% for any necessary corrections.
        ignore_dup_key = off, 
        statistics_norecompute  = off,     
        allow_row_locks  = on, 
        allow_page_locks  = on
    ) on psQuarterly(OrderDate)  --<-- Good Stuff - No longer on the Primary File Group
) on psQuarterly(OrderDate);

/****    End of Good Stuff    ****/



alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_RevisionNumber default ((0)) for RevisionNumber;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_OrderDate default (getdate()) for OrderDate;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_Status default ((1)) for Status;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_OnlineOrderFlag default ((1)) for OnlineOrderFlag;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_SubTotal default ((0.00)) for SubTotal;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_TaxAmt default ((0.00)) for TaxAmt;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_Freight default ((0.00)) for Freight;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_rowguid default (newid()) for rowguid;
go

alter table Sales.Tmp_SalesOrderHeader add constraint
	DF_SalesOrderHeader_ModifiedDate default (getdate()) for ModifiedDate;
go


set identity_insert Sales.Tmp_SalesOrderHeader on;
go
insert into Sales.Tmp_SalesOrderHeader (SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate)
		select SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate from Sales.SalesOrderHeader with (holdlock tablockx);
go
set identity_insert Sales.Tmp_SalesOrderHeader off;
go

alter table Sales.SalesOrderDetail
	drop constraint FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID;
go

alter table Sales.SalesOrderHeaderSalesReason
	drop constraint FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID;
go

-- Wizard created conversion scripts drop the old table.  I don't do that - I rename it.  That way
-- I can be more flexible reacting to issues.  But - it means I am responsible for dropping indexes
-- and triggers - resources implicitly dropped when you drop the table.

drop index AK_SalesOrderHeader_rowguid 
    on Sales.SalesOrderHeader;
go

drop index AK_SalesOrderHeader_SalesOrderNumber 
    on Sales.SalesOrderHeader;
go

drop index IX_SalesOrderHeader_CustomerID 
    on Sales.SalesOrderHeader;
go

drop index IX_SalesOrderHeader_SalesPersonID 
    on Sales.SalesOrderHeader;
go

drop trigger Sales.uSalesOrderHeader;
go
    
sp_rename 'Sales.SalesOrderHeader', 'BACKUPSalesOrderHeader', 'OBJECT';
go
sp_rename 'Sales.Tmp_SalesOrderHeader', 'SalesOrderHeader', 'OBJECT'; 
go


create unique nonclustered index AK_SalesOrderHeader_rowguid on Sales.SalesOrderHeader
(
	rowguid
) 
with
( 
    statistics_norecompute = off, 
    ignore_dup_key = off, 
    allow_row_locks = on, 
    allow_page_locks = on
) on [Primary];  
go

-- To align or not to align - that is the question here.  SalesOrderNumber is not highly selective.  In fact - just the opposite.
-- So you would not align it.  (Indeed in AdventureWorks2014 - it is a Unique index.  You CANNOT align it.)  But I want to make 
-- a point so ... liberties are taken...
create nonclustered index PIX_SalesOrderHeader_SalesOrderNumber on Sales.SalesOrderHeader
(
	SalesOrderNumber
) 
with
( 
    statistics_norecompute = off, 
    ignore_dup_key = off, 
    allow_row_locks = on, 
    allow_page_locks = on
) on psQuarterly(OrderDate);  
go

create nonclustered index PIX_SalesOrderHeader_CustomerID on Sales.SalesOrderHeader
(
    CustomerID
) 
with
( 
    statistics_norecompute = off, 
    ignore_dup_key = off, 
    allow_row_locks = on, 
    allow_page_locks = on
) on psQuarterly(OrderDate);  --<< Storage Aligned Index  (hence the PIX prefix)
go

create nonclustered index PIX_SalesOrderHeader_SalesPersonID on Sales.SalesOrderHeader
(
	SalesPersonID
) 
with
( 
    statistics_norecompute = off, 
    ignore_dup_key = off, 
    allow_row_locks = on, 
    allow_page_locks = on
) on psQuarterly(OrderDate);  --<< Storage Aligned Index  (hence the PIX prefix)


alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_Address_BillToAddressID foreign key
	(
	    BillToAddressID
	) 
	references Person.Address
	(
	    AddressID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_Address_ShipToAddressID foreign key
	(
	    ShipToAddressID
	) 
	references Person.Address
	(
	    AddressID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_CreditCard_CreditCardID foreign key
	(
	    CreditCardID
	) 
	references Sales.CreditCard
	(
	    CreditCardID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_CurrencyRate_CurrencyRateID foreign key
	(
	    CurrencyRateID
	) 
	references Sales.CurrencyRate
	(
	    CurrencyRateID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_Customer_CustomerID foreign key
	(
	    CustomerID
	) references Sales.Customer
	(
	    CustomerID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_SalesPerson_SalesPersonID foreign key
	(
	    SalesPersonID
	) 
	references Sales.SalesPerson
	(
	    BusinessEntityID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_ShipMethod_ShipMethodID foreign key
	(
	    ShipMethodID
	) 
	references Purchasing.ShipMethod
	(
	    ShipMethodID
	) on update no action 
	 on delete no action; 
go

alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_SalesTerritory_TerritoryID foreign key
	(
	    TerritoryID
	) 
	references Sales.SalesTerritory
	(
	    TerritoryID
	) on update no action 
	 on delete no action; 
go

create trigger Sales.uSalesOrderHeader on Sales.SalesOrderHeader 
after update not for replication as 
begin
    declare @Count int;
    set @Count = @@rowcount;
    if @Count = 0 
        return;
    set nocount on;
    begin try
        if not update(Status)
        begin
            update Sales.SalesOrderHeader
            set Sales.SalesOrderHeader.RevisionNumber = 
                Sales.SalesOrderHeader.RevisionNumber + 1
            where Sales.SalesOrderHeader.SalesOrderID IN 
                (select inserted.SalesOrderID from inserted);
        end;
        if update(SubTotal)
        begin
            declare @StartDate datetime,
                    @EndDate datetime
            set @StartDate = dbo.ufnGetAccountingStartDate();
            set @EndDate = dbo.ufnGetAccountingEndDate();
            update Sales.SalesPerson
                set Sales.SalesPerson.SalesYTD = 
                    (select sum(Sales.SalesOrderHeader.SubTotal)
            from Sales.SalesOrderHeader 
            where Sales.SalesPerson.BusinessEntityID = Sales.SalesOrderHeader.SalesPersonID
              and (Sales.SalesOrderHeader.Status = 5) -- Shipped
              and Sales.SalesOrderHeader.OrderDate between @StartDate and @EndDate)
            where Sales.SalesPerson.BusinessEntityID 
               in (select distinct inserted.SalesPersonID from inserted 
            where inserted.OrderDate between @StartDate and @EndDate);
            
            update Sales.SalesTerritory
                set Sales.SalesTerritory.SalesYTD = 
                    (select sum(Sales.SalesOrderHeader.SubTotal)
            from Sales.SalesOrderHeader 
            where Sales.SalesTerritory.TerritoryID = Sales.SalesOrderHeader.TerritoryID
              and (Sales.SalesOrderHeader.Status = 5) -- Shipped
              and Sales.SalesOrderHeader.OrderDate between @StartDate and @EndDate)
            where Sales.SalesTerritory.TerritoryID 
               in (select distinct inserted.TerritoryID from inserted 
            where inserted.OrderDate between @StartDate and @EndDate);
        end;
    end try
    begin catch
        execute dbo.uspPrintError;
        if @@trancount > 0
        begin
            rollback transaction;
        end
        execute dbo.uspLogError;
    end catch;
end;
go


use AdventureWorks2014;
go


set quoted_identifier on;
set arithabort on;
set numeric_roundabort off;
set concat_null_yields_null on;
set ansi_nulls on;
set ansi_padding on;
set ansi_warnings on;


go
alter table Sales.SalesOrderDetail
	drop constraint FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID;
go

alter table Sales.SalesOrderDetail
	drop constraint DF_SalesOrderDetail_UnitPriceDiscount;
go

alter table Sales.SalesOrderDetail
	drop constraint DF_SalesOrderDetail_rowguid;
go

alter table Sales.SalesOrderDetail
	drop constraint DF_SalesOrderDetail_ModifiedDate;
go
/*************************************************************************************/
/***                                                                               ***/
/***   Good Stuff Here.  I am                                                      ***/
/***   1)  Renaming the primary key of the old table so I can use that name        ***/
/***   2)  Adding the OrderDate column to the primary key on the new table         ***/
/***   3)  Allocating the new table on the partitioned file group                  ***/
/***                                                                               ***/
/*************************************************************************************/
     
sp_rename 'Sales.PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID', 'BACKUPPK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID', 'OBJECT'; 
go

drop index AK_SalesOrderDetail_rowguid on Sales.SalesOrderDetail;
go

drop index IX_SalesOrderDetail_ProductID on Sales.SalesOrderDetail;
go

alter table Sales.SalesOrderDetail drop constraint CK_SalesOrderDetail_OrderQty;
go

alter table Sales.SalesOrderDetail drop constraint CK_SalesOrderDetail_UnitPrice;
go

alter table Sales.SalesOrderDetail drop constraint CK_SalesOrderDetail_UnitPriceDiscount;
go


create table Sales.Tmp_SalesOrderDetail
(
	SalesOrderID                       int not null,
    OrderDate                          datetime not null,          -- I need to add the partition key to the table.
	SalesOrderDetailID                 int not null identity (1, 1),
	CarrierTrackingNumber              nvarchar(25) null,
	OrderQty                           smallint not null,
	ProductID                          int not null,
	SpecialOfferID                     int not null,
	UnitPrice                          money not null,
	UnitPriceDiscount                  money not null,
	LineTotal                          as (isnull((UnitPrice*((1.0)-UnitPriceDiscount))*OrderQty,(0.0))),
	rowguid                            uniqueidentifier not null rowguidcol,
	ModifiedDate                       datetime not null
    constraint PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID primary key clustered 
    (
        SalesOrderID asc,
        OrderDate asc,
        SalesOrderDetailID asc
    ) 
    with 
    ( 
        pad_index  = on, 
        fillfactor = 95,      -- should be 100% - but leave 5% for any necessary corrections.
        ignore_dup_key = off, 
        statistics_norecompute  = off,     
        allow_row_locks  = on, 
        allow_page_locks  = on
    ) on psQuarterly(OrderDate)  --<-- Again - magic here.
) on psQuarterly(OrderDate);
go

/****    End of Good Stuff    ****/

alter table Sales.Tmp_SalesOrderDetail add constraint
	DF_SalesOrderDetail_UnitPriceDiscount default ((0.0)) for UnitPriceDiscount;
go

alter table Sales.Tmp_SalesOrderDetail add constraint
	DF_SalesOrderDetail_rowguid default (newid()) for rowguid
go

alter table Sales.Tmp_SalesOrderDetail add constraint
	DF_SalesOrderDetail_ModifiedDate default (getdate()) for ModifiedDate
go


-- Because we added the OrderDate to the key - we have to join the header table to get that column.

set identity_insert Sales.Tmp_SalesOrderDetail on;
go
insert into Sales.Tmp_SalesOrderDetail 
(
    SalesOrderID, 
    OrderDate,
    SalesOrderDetailID, 
    CarrierTrackingNumber, 
    OrderQty, 
    ProductID, 
    SpecialOfferID, 
    UnitPrice, 
    UnitPriceDiscount, 
    rowguid, 
    ModifiedDate
)
select 
    sod.SalesOrderID, 
    soh.OrderDate,
    sod.SalesOrderDetailID, 
    sod.CarrierTrackingNumber, 
    sod.OrderQty, 
    sod.ProductID, 
    sod.SpecialOfferID, 
    sod.UnitPrice, 
    sod.UnitPriceDiscount, 
    sod.rowguid, 
    sod.ModifiedDate 
from 
        Sales.SalesOrderDetail sod with (holdlock tablockx)
    inner join
        Sales.SalesOrderHeader soh with (holdlock tablockx)
            on soh.SalesOrderID = sod.SalesOrderID;    
go
set identity_insert Sales.Tmp_SalesOrderDetail off;
go

sp_rename 'Sales.SalesOrderDetail', 'BACKUPSalesOrderDetail', 'OBJECT'; 
go
sp_rename 'Sales.Tmp_SalesOrderDetail', 'SalesOrderDetail', 'OBJECT'; 
go


create unique nonclustered index AK_SalesOrderDetail_rowguid on Sales.SalesOrderDetail
(
	rowguid
) 
with
( 
    statistics_norecompute = off, 
    ignore_dup_key = off, 
    allow_row_locks = on, 
    allow_page_locks = on
) on [Primary]; 
go

create nonclustered index PIX_SalesOrderDetail_ProductID on Sales.SalesOrderDetail
    (
	     ProductID
    ) 
    with
    ( 
        statistics_norecompute = off, 
        ignore_dup_key = off, 
        allow_row_locks = on, 
        allow_page_locks = on
    ) 
    on psQuarterly(OrderDate);  --<< Storage Aligned Index (hence the PIX prefix)
go


alter table Sales.SalesOrderDetail with check add constraint
	CK_SalesOrderDetail_OrderQty check ((OrderQty>(0)));
go

alter table Sales.SalesOrderDetail with check add constraint
	CK_SalesOrderDetail_UnitPrice check ((UnitPrice>=(0.00)));
go

alter table Sales.SalesOrderDetail with check add constraint
	CK_SalesOrderDetail_UnitPriceDiscount check ((UnitPriceDiscount>=(0.00)));
go

alter table Sales.SalesOrderDetail with check add constraint
	FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID foreign key
	(
	    SpecialOfferID,
	    ProductID
	) 
	references Sales.SpecialOfferProduct
	(
	    SpecialOfferID,
	    ProductID
	) on update  no action 
	 on delete  no action; 
go

alter table Sales.SalesOrderDetail with check add constraint
	FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID foreign key
	(
	    SalesOrderID,
	    OrderDate
	) 
	references Sales.SalesOrderHeader
	(
	    SalesOrderID,
	    OrderDate
	) on update no action 
	 on delete  cascade; 
go	

use AdventureWorks2014;
go

set quoted_identifier on;
set arithabort on;
set numeric_roundabort off;
set concat_null_yields_null on;
set ansi_nulls on;
set ansi_padding on;
set ansi_warnings on;


go
alter table Sales.SalesOrderHeaderSalesReason
	drop constraint FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID;
go


alter table Sales.SalesOrderHeaderSalesReason
	drop constraint DF_SalesOrderHeaderSalesReason_ModifiedDate;
go


/*************************************************************************************/
/***                                                                               ***/
/***   Good Stuff Here.  I am                                                      ***/
/***   1)  Renaming the primary key of the old table so I can use that name        ***/
/***   2)  Adding the OrderDate column to the primary key on the new table         ***/
/***   3)  Allocating the new table on the partitioned file group                  ***/
/***                                                                               ***/
/*************************************************************************************/
     
sp_rename 'Sales.PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID', 'BACKUPPK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID', 'OBJECT'; 
go

create table Sales.Tmp_SalesOrderHeaderSalesReason
(
	SalesOrderID                       int not null,
    OrderDate                          datetime not null,
	SalesReasonID                      int not null,
	ModifiedDate                       datetime not null    --<<  Our developers cool ORM tool may not like this!!!
    constraint PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID primary key clustered 
    (
        SalesOrderID asc,
        OrderDate asc,
        SalesReasonID asc
    ) 
    with 
    ( 
        pad_index  = on, 
        fillfactor = 95,      -- should be 100% - but leave 5% for any necessary corrections.
        ignore_dup_key = off, 
        statistics_norecompute  = off,     
        allow_row_locks  = on, 
        allow_page_locks  = on
    ) on psQuarterly(OrderDate)
) on psQuarterly(OrderDate);
go

alter table Sales.Tmp_SalesOrderHeaderSalesReason add constraint
	DF_SalesOrderHeaderSalesReason_ModifiedDate default (GetDate()) for ModifiedDate;
go


insert into Sales.Tmp_SalesOrderHeaderSalesReason 
(
    SalesOrderID,
    OrderDate, 
    SalesReasonID, 
    ModifiedDate
)
select 
    sohsr.SalesOrderID, 
    soh.OrderDate,
    sohsr.SalesReasonID, 
    sohsr.ModifiedDate 
from 
        Sales.SalesOrderHeaderSalesReason sohsr with (holdlock tablockx)
    inner join 
        Sales.SalesOrderHeader soh with (holdlock tablockx)
            on sohsr.SalesOrderID = soh.SalesOrderID;
go

sp_rename 'Sales.SalesOrderHeaderSalesReason', 'BACKUPSalesOrderHeaderSalesReason', 'OBJECT'; 
go
sp_rename 'Sales.Tmp_SalesOrderHeaderSalesReason', 'SalesOrderHeaderSalesReason', 'OBJECT'; 
go


alter table Sales.SalesOrderHeaderSalesReason with check add constraint
	FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID foreign key
	(
	    SalesReasonID
	) 
	references Sales.SalesReason
	(
	    SalesReasonID
	) 
	on update  no action 
	on delete  no action; 
	
go

-- From our "To Do" list
alter table Sales.SalesOrderHeaderSalesReason add constraint
	FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID foreign key
	(
	    SalesOrderID,
	    OrderDate
	) 
	    references Sales.SalesOrderHeader
	(
	    SalesOrderID,
	    OrderDate
	) 
	on update no action 
	on delete  cascade; 
go

