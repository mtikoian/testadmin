use AdventureWorks2014Replica;
go

if  exists (select * from sys.objects where object_id = object_id('Sales.SalesOrderHeader') and type in ('U'))
    drop table Sales.SalesOrderHeader;
go

create table Sales.SalesOrderHeader
(
	SalesOrderID                       int not null,                 -- Notice - I took out the identity.
	RevisionNumber                     tinyint not null,
	OrderDate                          datetime not null,
	DueDate                            datetime not null,
	ShipDate                           datetime null,
	Status                             tinyint not null,
	OnlineOrderSourceCodeId            int not null,              
	SalesOrderNumber                   as (isnull(N'SO'+convert([nvarchar](23),[SalesOrderID],0),N'*** ERROR ***')),
	PurchaseOrderNumber                nvarchar(25) null,            -- and I replaced the UDTs with their base datatype.
	AccountNumber                      nvarchar(15) null,
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


-- I will create indexes here.  If this were the real world - I would create the indexes after copying the data.

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
