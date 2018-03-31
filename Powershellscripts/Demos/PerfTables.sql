CREATE TABLE [Analysis].[ServerStats] (
    ServerID    int IDENTITY(1,1) NOT NULL,
    ServerNm    varchar(30) NOT NULL,
    PerfDate    datetime NOT NULL,
    PctProc     decimal(10,4) NOT NULL,
    Memory      bigint NOT NULL,
    PgFilUse    decimal(10,4) NOT NULL,
    DskSecRd    decimal(10,4) NOT NULL,
    DskSecWrt   decimal(10,4) NOT NULL,
    ProcQueLn   int NOT NULL
    CONSTRAINT [PK_ServerStats] PRIMARY KEY CLUSTERED 
    (
        [ServerID] ASC
    )
)
GO

CREATE TABLE [Analysis].[InstanceStats] (
    InstanceID  int IDENTITY(1,1) NOT NULL,
    ServerID    int NOT NULL,
    ServerNm    varchar(30) NOT NULL,
    InstanceNm  varchar(30) NOT NULL,
    PerfDate    datetime NOT NULL,
    FwdRecSec   decimal(10,4) NOT NULL,
    PgSpltSec   decimal(10,4) NOT NULL,
    BufCchHit   decimal(10,4) NOT NULL,
    PgLifeExp   int NOT NULL,
    LogGrwths   int NOT NULL,
    BlkProcs    int NOT NULL,
    BatReqSec   decimal(10,4) NOT NULL,
    SQLCompSec  decimal(10,4) NOT NULL,
    SQLRcmpSec  decimal(10,4) NOT NULL
    CONSTRAINT [PK_InstanceStats] PRIMARY KEY CLUSTERED 
    (
        [InstanceID] ASC
    )
)
GO
ALTER TABLE [Analysis].[InstanceStats] WITH CHECK ADD  CONSTRAINT [FX_InstanceStats] FOREIGN KEY([ServerID])
REFERENCES [Analysis].[ServerStats] ([ServerID])
GO

ALTER TABLE [Analysis].[InstanceStats] CHECK CONSTRAINT [FX_InstanceStats] 
GO
CREATE NONCLUSTERED INDEX [AK_ServerStats] ON [Analysis].[InstanceStats] 
(
    [ServerID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_ServerStats_PerfDate] ON [Analysis].[ServerStats] 
(
    [PerfDate] ASC
)
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insServerStats]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Analysis].[insServerStats]
GO
CREATE PROCEDURE [Analysis].[insServerStats]
           (@ServerID       int OUTPUT
           ,@ServerNm       varchar(30) = NULL
           ,@PerfDate       datetime = NULL
           ,@PctProc        decimal(10,4) = NULL
           ,@Memory     bigint = NULL
           ,@PgFilUse       decimal(10,4) = NULL
           ,@DskSecRd       decimal(10,4) = NULL
           ,@DskSecWrt      decimal(10,4) = NULL
           ,@ProcQueLn      int = NULL)
AS
    SET NOCOUNT ON
    
    DECLARE @ServerOut table( ServerID int);

    INSERT INTO [Analysis].[ServerStats]
           ([ServerNm]
           ,[PerfDate]
           ,[PctProc]
           ,[Memory]
           ,[PgFilUse]
           ,[DskSecRd]
           ,[DskSecWrt]
           ,[ProcQueLn])
    OUTPUT INSERTED.ServerID INTO @ServerOut
        VALUES
           (@ServerNm
           ,@PerfDate
           ,@PctProc
           ,@Memory
           ,@PgFilUse
           ,@DskSecRd
           ,@DskSecWrt
           ,@ProcQueLn)

    SELECT @ServerID = ServerID FROM @ServerOut
    
    RETURN

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insInstanceStats]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Analysis].[insInstanceStats]
GO
CREATE PROCEDURE [Analysis].[insInstanceStats]
           (@InstanceID     int OUTPUT
           ,@ServerID       int = NULL
           ,@ServerNm       varchar(30) = NULL
           ,@InstanceNm     varchar(30) = NULL
           ,@PerfDate       datetime = NULL
           ,@FwdRecSec      decimal(10,4) = NULL
           ,@PgSpltSec      decimal(10,4) = NULL
           ,@BufCchHit      decimal(10,4) = NULL
           ,@PgLifeExp      int = NULL
           ,@LogGrwths      int = NULL
           ,@BlkProcs       int = NULL
           ,@BatReqSec      decimal(10,4) = NULL
           ,@SQLCompSec     decimal(10,4) = NULL
           ,@SQLRcmpSec     decimal(10,4) = NULL)
AS
    SET NOCOUNT ON
    
    DECLARE @InstanceOut table( InstanceID int);

    INSERT INTO [Analysis].[InstanceStats]
           ([ServerID]
           ,[ServerNm]
           ,[InstanceNm]
           ,[PerfDate]
           ,[FwdRecSec]
           ,[PgSpltSec]
           ,[BufCchHit]
           ,[PgLifeExp]
           ,[LogGrwths]
           ,[BlkProcs]
           ,[BatReqSec]
           ,[SQLCompSec]
           ,[SQLRcmpSec])
    OUTPUT INSERTED.InstanceID INTO @InstanceOut
    VALUES
           (@ServerID
           ,@ServerNm
           ,@InstanceNm
           ,@PerfDate
           ,@FwdRecSec
           ,@PgSpltSec
           ,@BufCchHit
           ,@PgLifeExp
           ,@LogGrwths
           ,@BlkProcs
           ,@BatReqSec
           ,@SQLCompSec
           ,@SQLRcmpSec)

    SELECT @InstanceID = InstanceID FROM @InstanceOut
    
    RETURN

GO
