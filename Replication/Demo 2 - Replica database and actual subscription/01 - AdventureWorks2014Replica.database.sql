use master;
go


if  exists (select name from sys.databases where name = 'AdventureWorks2014Replica')
begin
    alter database AdventureWorks2014Replica set  single_user with rollback immediate;

    drop database AdventureWorks2014Replica;
end
go

create database AdventureWorks2014Replica on
    primary                 (name= 'AdventureWorks2014Replica', filename = 'c:\data00\Data\AdventureWorks2014Replica.mdf', size = 200MB, maxsize = unlimited, filegrowth = 5MB), 
    filegroup Trans2011Q2  (name= 'Trans2011Q2', filename = 'c:\data00\Data\Trans2011Q2r.ndf', size = 1mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2011Q3  (name= 'Trans2011Q3', filename = 'c:\data00\Data\Trans2011Q3r.ndf', size = 1mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2011Q4  (name= 'Trans2011Q4', filename = 'c:\data00\Data\Trans2011Q4r.ndf', size = 1mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2012Q1  (name= 'Trans2012Q1', filename = 'c:\data00\Data\Trans2012Q1r.ndf', size = 1mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2012Q2  (name= 'Trans2012Q2', filename = 'c:\data00\Data\Trans2012Q2r.ndf', size = 2mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2012Q3  (name= 'Trans2012Q3', filename = 'c:\data00\Data\Trans2012Q3r.ndf', size = 2mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2012Q4  (name= 'Trans2012Q4', filename = 'c:\data00\Data\Trans2012Q4r.ndf', size = 2mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2013Q1  (name= 'Trans2013Q1', filename = 'c:\data00\Data\Trans2013Q1r.ndf', size = 2mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2013Q2  (name= 'Trans2013Q2', filename = 'c:\data00\Data\Trans2013Q2r.ndf', size = 4mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2013Q3  (name= 'Trans2013Q3', filename = 'c:\data00\Data\Trans2013Q3r.ndf', size = 5mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2013Q4  (name= 'Trans2013Q4', filename = 'c:\data00\Data\Trans2013Q4r.ndf', size = 4mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2014Q1  (name= 'Trans2080Q2', filename = 'c:\data00\Data\Trans2014Q1r.ndf', size = 5mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup Trans2014Q2  (name= 'Trans2014Q2', filename = 'c:\data00\Data\Trans2014Q2r.ndf', size = 10mb,  maxsize = unlimited, filegrowth = 500kb), 
    filegroup TransFuture  (name= 'TransFuture', filename = 'c:\data00\Data\TransFuturer.ndf', size = 4mb,  maxsize = unlimited, filegrowth = 500kb) 
    log on                  (name= 'AdventureWorks2012ReplicaLog', filename = 'c:\log00\TransactionLog\AdventureWorks2012ReplicaLog.ldf',size = 5mb, maxsize = unlimited, filegrowth = 5mb);
go

exec dbo.sp_dbcmptlevel @dbname='AdventureWorks2014Replica', @new_cmptlevel=110;
go



alter database AdventureWorks2014Replica set ansi_null_default off; 
go
alter database AdventureWorks2014Replica set ansi_nulls off; 
go
alter database AdventureWorks2014Replica set ansi_padding off; 
go
alter database AdventureWorks2014Replica set ansi_warnings off; 
go
alter database AdventureWorks2014Replica set arithabort off; 
go
alter database AdventureWorks2014Replica set auto_close off; 
go
alter database AdventureWorks2014Replica set auto_create_statistics on; 
go
alter database AdventureWorks2014Replica set auto_shrink off; 
go
alter database AdventureWorks2014Replica set auto_update_statistics on; 
go
alter database AdventureWorks2014Replica set cursor_close_on_commit off; 
go
alter database AdventureWorks2014Replica set cursor_default  global; 
go
alter database AdventureWorks2014Replica set concat_null_yields_null off; 
go
alter database AdventureWorks2014Replica set numeric_roundabort off; 
go
alter database AdventureWorks2014Replica set quoted_identifier off; 
go
alter database AdventureWorks2014Replica set recursive_triggers off; 
go
alter database AdventureWorks2014Replica set  enable_broker; 
go
alter database AdventureWorks2014Replica set auto_update_statistics_async off; 
go
alter database AdventureWorks2014Replica set date_correlation_optimization off; 
go
alter database AdventureWorks2014Replica set trustworthy off; 
go
alter database AdventureWorks2014Replica set allow_snapshot_isolation off; 
go
alter database AdventureWorks2014Replica set parameterization simple; 
go
alter database AdventureWorks2014Replica set  read_write; 
go
alter database AdventureWorks2014Replica set recovery simple; 
go
alter database AdventureWorks2014Replica set  multi_user; 
go
alter database AdventureWorks2014Replica set page_verify checksum;

alter database AdventureWorks2014Replica set db_chaining off;
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------

use AdventureWorks2014Replica;
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
go

-- Very Important - Create the schemas you will need.

create schema HumanResources authorization dbo;
go

create schema Person authorization dbo;
go

create schema Production authorization dbo;
go

create schema Purchasing authorization dbo;
go

create schema Sales authorization dbo;
go


-- And any functions as well.....


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[ufnLeadingZeros](
    @Value int
) 
RETURNS varchar(8) 
WITH SCHEMABINDING 
AS 
BEGIN
    DECLARE @ReturnValue varchar(8);

    SET @ReturnValue = CONVERT(varchar(8), @Value);
    SET @ReturnValue = REPLICATE('0', 8 - DATALENGTH(@ReturnValue)) + @ReturnValue;

    RETURN (@ReturnValue);
END;

GO






CREATE FUNCTION [dbo].[ufnGetAccountingEndDate]()
RETURNS [datetime] 
AS 
BEGIN
    RETURN DATEADD(millisecond, -2, CONVERT(datetime, '20040701', 112));
END;

GO




CREATE FUNCTION [dbo].[ufnGetAccountingStartDate]()
RETURNS [datetime] 
AS 
BEGIN
    RETURN CONVERT(datetime, '20030701', 112);
END;

GO




CREATE FUNCTION [dbo].[ufnGetDocumentStatusText](@Status [tinyint])
RETURNS [nvarchar](16) 
AS 
-- Returns the sales order status text representation for the status value.
BEGIN
    DECLARE @ret [nvarchar](16);

    SET @ret = 
        CASE @Status
            WHEN 1 THEN N'Pending approval'
            WHEN 2 THEN N'Approved'
            WHEN 3 THEN N'Obsolete'
            ELSE N'** Invalid **'
        END;
    
    RETURN @ret
END;

GO












