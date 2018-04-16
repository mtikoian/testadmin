/***************************************************************************************************************
 =====================================
 = Parameter Sniffing Demonstration  =
 =====================================

 Author: Josh Feierman
 
 This script demonstrates how parameter sniffing (normally a desired behavior)
 can result in poor performance when dealing with disparate data sets (i.e. 
 data sets that can differ in size across various categories).
 
 In this case, we have two sets of financial accounts:
 
 1. Set 1 - 100 accounts (Administrator_ID 1)
 2. Set 2 - 10000 accounts (Administrator_ID 2)
 
 We illustrate how if a piece of code is called initially with 
 a smaller data set, it can perform poorly in subsequent executions
 due to the cached query plan.
 
***************************************************************************************************************/       
use [master];

if exists (select 1 from sys.databases where [name] = 'ParameterSniffDemo') begin 
  alter database ParameterSniffDemo set single_user with rollback immediate;
  drop database ParameterSniffDemo;
end

create database ParameterSniffDemo;
go

/*********************************************************
 Create objects
 *********************************************************/
use ParameterSniffDemo;
go

if exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Account')
  drop table dbo.Account;
  
create table dbo.Account
(
  Account_Key int identity(1,1),
  Account_ID int,
  Administrator_ID int,
  primary key clustered (Account_Key),
  unique (Account_ID,Administrator_ID)
);

if exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Financial_Transaction')
  drop table dbo.Financial_Transaction;
  
create table dbo.Financial_Transaction
(
  Financial_Transaction_ID int identity(1,1),
  Account_Key int,
  Transaction_Amt money,
  primary key clustered (Financial_Transaction_ID),
  foreign key (Account_Key) references dbo.Account(Account_Key)
);

create nonclustered index nci_Financial_Transaction_Account on dbo.Financial_Transaction
(
  Account_Key
)
include
(
  Transaction_Amt
);

/**********************************
 Load data
 *********************************/
declare @start_num int;
declare @max_num int;
declare @increment int;

-- Create one accountant with 100 accounts
with Numbers AS
(
  select
    row_number() over(order by sc1.column_id) as N
  from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
)
insert dbo.Account
(
  Administrator_ID,
  Account_ID
)
select top 100
  1 AS Administrator_ID,
  N.N AS Account_ID
from 
  Numbers N;

set @start_num = 0;
set @max_num = 1000;
set @increment = 100;

while @start_num <= @max_num begin

  ;with Numbers AS
  (
    select
      row_number() over(order by sc1.column_id) as N
    from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
  )
  insert dbo.financial_transaction
  (
    Account_Key,
    Transaction_Amt
  )
  select
    Account_Key,
    n.N
  from
    dbo.Account ac cross join Numbers n
  where
    ac.Administrator_ID = 1
    and N >= @start_num
    and N < @start_num + @increment
  order by
    ac.Administrator_ID,
    ac.Account_ID;

  set @start_num = @start_num + @increment;
  raiserror('Start: %i',10,1,@start_num) with nowait;

end


-- Create one accountant with 10000 accounts
;with Numbers AS
(
  select
    row_number() over(order by sc1.column_id) as N
  from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
)
insert dbo.Account
(
  Administrator_ID,
  Account_ID
)
select top 10000
  2 AS Administrator_ID,
  N.N AS Account_ID
from 
  Numbers N;

set @start_num = 0;
set @max_num = 100;
set @increment = 25;

while @start_num <= @max_num begin

  begin tran;

  ;with Numbers AS
  (
    select
      row_number() over(order by sc1.column_id) as N
    from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
  )
  insert dbo.financial_transaction
  (
    Account_Key,
    Transaction_Amt
  )
  select
    Account_Key,
    n.N
  from
    dbo.Account ac cross join Numbers n
  where
    ac.Administrator_ID = 2
    and N >= @start_num
    and N < @start_num + @increment
  order by
    ac.Administrator_ID,
    ac.Account_ID;

  commit;

  set @start_num = @start_num + @increment;
  raiserror('Start: %i',10,1,@start_num) with nowait;

end
  
go

/****************************************************
 Create procedure to select results by Admin
 ****************************************************/

if exists(select 1 from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'GetTransactionByAdministrator')
  drop procedure dbo.GetTransactionByAdministrator;
go

create procedure dbo.GetTransactionByAdministrator
  @pi_Administrator_ID int
as
set nocount on;
select
  acct.Account_ID,
  ft.Transaction_Amt
from
  dbo.Account acct join dbo.Financial_Transaction ft
    on acct.Account_Key = ft.Account_Key
where 
  acct.Administrator_ID = @pi_Administrator_ID;
go


/******************************
 Observe sniffing gone bad...
 *****************************/

-- Clear procedure cache and execute using the 'smaller' result.
-- Make sure you have "Include Actual Execution Plan enabled.
-- We also enable STATISTICS IO to gather table by table IO stats,
-- and STATISTICS TIME to gather execution stats.
-- Observe that the plan used is a Loop Join with an Index Seek.
set statistics IO on;
set statistics time on;

dbcc freeproccache;
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  

-- Now execute the second procedure, noting that the same plan is used.
-- Look at the Actual versus Estimated row counts for the inner and outer tables.
-- Also note the "CPU time" entries (don't pay attention to the "elapsed" ones since
-- they are mostly from rendering the results).
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;

-- Now we'll clear the procedure cache and re-run with the "large" result.
-- Observe that the plan is different and that the estimated rowcounts are accurate.
-- Also note that the CPU time and logical reads are lower, especially the logical reads.
-- Loop joins are expensive IO wise with large results.
dbcc freeproccache;
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;
go


/************************************************
 Solution #1: Specify WITH RECOMPILE at the 
 stored procedure level.

 Will correct the problem but will add CPU overhead
 upon every execution. This can add up for expensive /
 complex plans in frequently executed procedures.

 *************************************************/
alter procedure dbo.GetTransactionByAdministrator
  @pi_Administrator_ID int
with recompile -- newly added
as
set nocount on;
select
  acct.Account_ID,
  ft.Transaction_Amt
from
  dbo.Account acct join dbo.Financial_Transaction ft
    on acct.Account_Key = ft.Account_Key
where 
  acct.Administrator_ID = @pi_Administrator_ID;
go

dbcc freeproccache;
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  

-- Now execute the second procedure, noting that a different plan is used.
-- The "actual" and "Estimated" row counts are equal.
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;
go

/************************************************
 Solution #2: Specify WITH RECOMPILE at the 
 statement level.

 Will correct the problem but will add CPU overhead
 upon every execution. However this can result in less
 overhead than a full procedure level recompile, especially
 if the procedure is complex (it is not in this case, we simply
 demonstrate the method here).

 *************************************************/
alter procedure dbo.GetTransactionByAdministrator
  @pi_Administrator_ID int
as
set nocount on;
select
  acct.Account_ID,
  ft.Transaction_Amt
from
  dbo.Account acct join dbo.Financial_Transaction ft
    on acct.Account_Key = ft.Account_Key
where 
  acct.Administrator_ID = @pi_Administrator_ID
option(recompile); -- newly added
go

dbcc freeproccache;
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  

-- Now execute the second procedure, noting that a different plan is used.
-- The "actual" and "Estimated" row counts are equal.
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;
go

/************************************************
 Solution #3: Use local variables in place of parameters.

 By using a local variable in place of a parameter, we
 force the optimizer to make a "best guess" at the 
 cardinality of the query, since it cannot sniff runtime
 values. This can improve performance but can also make it 
 worse depending upon the data distribution.

 *************************************************/
alter procedure dbo.GetTransactionByAdministrator
  @pi_Administrator_ID int
as
set nocount on;

-- New code begin
declare @local_Administrator_ID int;
set @local_Administrator_ID = @pi_Administrator_ID;
-- New code end

select
  acct.Account_ID,
  ft.Transaction_Amt
from
  dbo.Account acct join dbo.Financial_Transaction ft
    on acct.Account_Key = ft.Account_Key
where 
  acct.Administrator_ID = @local_Administrator_ID; -- Changed here
go

-- Clear cache and observe that the plan used even with the "small" result
-- looks similar to the optimal "large" plan.
dbcc freeproccache;
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  

-- Now execute the second procedure, noting that the same (and now
-- optimal) plan is used.
exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;




set statistics IO off;
set statistics time off;  