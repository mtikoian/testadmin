use AdventureWorks2014;
go

-- Because I took a backup earlier....
if  exists (select * from sys.objects where object_id = object_id('Sales.BACKUPSalesOrderHeader') and type in ('U'))
    drop table Sales.BACKUPSalesOrderHeader;
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
	OnlineOrderSourceCodeId            int not null,              -- replaces OnlineOrderFlag      dbo.Flag not null,
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
        fillfactor = 95,      
        ignore_dup_key = off, 
        statistics_norecompute  = off,     
        allow_row_locks  = on, 
        allow_page_locks  = on
    ) on psQuarterly(OrderDate)  
) on psQuarterly(OrderDate);





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
insert into Sales.Tmp_SalesOrderHeader (SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderSourceCodeId, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate)
		select SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, case OnlineOrderFlag when 1 then 1 else -1 end, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate from Sales.SalesOrderHeader with (holdlock tablockx);
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

drop index PIX_SalesOrderHeader_CustomerID 
    on Sales.SalesOrderHeader;
go

drop index PIX_SalesOrderHeader_SalesOrderNumber
    on Sales.SalesOrderHeader;
go

drop index PIX_SalesOrderHeader_SalesPersonID 
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



alter table Sales.SalesOrderHeaderSalesReason with check add constraint
	FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID foreign key
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

-- New foreign Key to the Sales.OnlineOrderSourceCode
alter table Sales.SalesOrderHeader with check add constraint
	FK_SalesOrderHeader_OnlineOrderSourceCode foreign key
	(
	    OnlineOrderSourceCodeID
	) 
	references Sales.OnlineOrderSourceCode
	(
	    OnlineOrderSourceCodeID
	) on update no action 
	 on delete  cascade; 
	
go
