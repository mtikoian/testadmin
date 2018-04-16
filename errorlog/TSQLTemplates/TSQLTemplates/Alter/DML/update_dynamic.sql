Create table dbo.Admin( SourceTableName VARCHAR(100),ColumnName VARCHAR(100),Status_fl CHAR(1))
go
insert into dbo.Admin values ( 'dbo.Src','NAME','Y')
go
insert into dbo.Admin values ( 'dbo.Src','ADDRESS','N')
go
insert into dbo.Admin values ( 'dbo.Src','AGE','Y')
go
insert into dbo.Admin values ( 'dbo.Src1','FName','Y')
go
insert into dbo.Admin values ( 'dbo.Src2','LName','N')
go
insert into dbo.Admin values ( 'dbo.Src2','SSN','Y')
go
insert into dbo.Admin values ( 'dbo.Src','phone','Y')
go

update Src a
set a.name = replace(a.name,'s','t')
,a.age = replace(a.name,'2','3')


here is the structure of the src table

Create table dbo.src 
(
ID int Identity(1,1)  PRIMARY KEY CLUSTERED 
,Name varchar(100)
,Address varchar(255)
,Phone varchar(25)
,Age INT
)
insert into src values ('sam','main street pa', '123-456-789', 30)
insert into src values ('tim','state street pa', '134-456-789', 20)

Create table dbo.src1 
(
ID_scr1 int Identity(1,1)  PRIMARY KEY CLUSTERED 
,FNAME varchar(100)
,LNAME varchar(255)
)
insert into src1 values ('sam','john')
insert into src1 values ('jim','tim')
insert into src1 values ('kim','tom')

CREATE TABLE dbo.scr2
(
phone varchar(30)
)

insert into scr2 values(234-456-7899)
insert into scr2 values(222-436-7339)

These tables dont have any relationship. the reason i am creating a admin table is to store which columns i need to update tomorrow i may need to add new column 
or remove a column. For this i have included a flag Y or N so that i can generate update statement based on Status_fl  column
i want to update string columns (name, address , country)
In this secnario is to REPLACE S with t and number columns (age, phone) is to replace 2 with 3.  










  WITH tempCTE(SrvName,Dest_DB) 
     AS(SELECT srvname,
               dest_db 
          FROM syssubscriptions SS
          JOIN sysarticles SA ON(SS.artid=SA.artid) 
         WHERE SA.pubid=@PubId
         GROUP BY srvname,dest_db)
         
         
         WITH tempCTE (SourceTableName , DestinationTableName, ColumnName , JoiningKey, Active)
         as   (select SourceTableName , DestinationTableName, ColumnName , [JoiningKey], [Active]
  
  from dbo.UpdateDef
  
  where Active = 'Y')


Declare @VARSQL VARCHAR(MAX)
SET @VARSQL=
(SELECT DISTINCT Replace ( COL,'=SET',',SET') AS QUERY FROM (
SELECT 'Update  D '+
(SELECT Stuff(
   (SELECT N'=SET D. ' + ColumnName +N'=S. ' + ColumnName FROM dbo.UpdateDef I WHERE I.Active='Y' FOR XML PATH(''),TYPE)
   .value('text()[1]','nvarchar(max)'),1,1,N'')
   )+' FROM '+JoiningKey
   AS COL
  FROM dbo.UpdateDef O
  WHERE 
  --DestinationTableName='Dbo.Dest'
  --AND 
  Active='Y'
) D
)

Print @VARSQL
--EXEC (@VARSQL)


UPDATE A
		SET a.[Mailto] = dbo.f_scrambledata(a.[Mailto])
			,a.[IPCAccountName] = dbo.f_scrambledata(a.[IPCAccountName])
			,a.[IPCSleeveAccountName] = dbo.f_scrambledata(a.[IPCSleeveAccountName])
		FROM [netikext].[ims].[IPCClientAccountSleeve] A
		JOIN [netikext].[ims].[IPCClientAccountSleeve] B ON A.PK_CI_SleeveAccountID = B.PK_CI_SleeveAccountID
		
   WITH tempCTE(SrvName,Dest_DB) 
     AS(SELECT srvname,
               dest_db 
          FROM syssubscriptions SS
          JOIN sysarticles SA ON(SS.artid=SA.artid) 
         WHERE SA.pubid=@PubId
         GROUP BY srvname,dest_db)
     
    SELECT @SQLCMD = COALESCE(@SQLCMD  , '') +  '       
    IF NOT EXISTS(SELECT 1  FROM sysextendedarticlesview  SA JOIN syspublications SP ON SA.pubid=SP.pubid JOIN syssubscriptions SS ON SA.artid=SS.artid 
                  WHERE dest_table=''Allocate_Gain_Loss'' AND SP.name=''PublishBISTables'')
    BEGIN
    exec sp_addsubscription @publication = ''PublishBISTables'', 
                                @subscriber ='''+ srvName +''', 
                                @destination_db =''' + Dest_DB +''', 
                                @subscription_type = N''Push'', 
                                @sync_type = N''automatic'', 
                                @article = N''Allocate_Gain_Loss'', 
                                @reserved = ''Internal'' END'
     FROM tempCTE;
    SET @SQLCMD = 'USE $(BISMasterDatabaseName) '+ @SQLCMD;
    EXECUTE sp_executesql @SQLCMD;   
DECLARE @max INT
DECLARE @cnt INT
DECLARE @lstr VARCHAR(max)
DECLARE @tablename VARCHAR(30)
DECLARE @columnname VARCHAR(50)
declare @adminupdate table ( id int identity, tablename varchar(30), columnname varchar(50), Status_fl  char(1))
insert into @adminupdate(tablename, columnname ,Status_fl )( SELECT SourceTableName as tablename , ColumnName as columnname , Status_fl as Status_fl from Admin);
select * from @adminupdate
SELECT @max = MAX(id)

FROM @adminupdate

SET @cnt = 1

WHILE (@cnt < = @max)
BEGIN
	SELECT @lstr = ''
		,@tablename = ''
		,@columnname = ''

	SELECT @columnname = columnname
		,@tablename = tablename
	FROM @adminupdate
	WHERE id = @cnt
		AND Status_fl = 'y'

	SET @lstr = 'UPDATE dbo.' + @tablename + ' SET ' + @columnname + ' = REPLACE(' + @columnname + ' ''S'', ''t'')'

	PRINT @lstr

	SET @cnt = @cnt + 1
END
