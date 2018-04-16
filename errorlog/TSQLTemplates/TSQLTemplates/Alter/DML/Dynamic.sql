use netikdp
go

drop table #temp22
Declare @sqlcmd nvarchar(max);
DECLARE @ErrorMessage NVARCHAR(4000)    ; SET @ErrorMessage = '';
DECLARE @ErrorSeverity INTEGER          ; SET @ErrorSeverity = 0;
DECLARE @ErrorState INTEGER             ; SET @ErrorState = 0;
DECLARE @rowcount INT					; SET @rowcount = 0;
DECLARE @INFORMATION nvarchar(4000)     ; SET @INFORMATION = '';
declare @txt varchar(40)   ;
 declare @DB_admin table 
( 
	--id int identity, 
	DB_Nme  varchar(10),
	tablename varchar(30), 
	columnname varchar(50), 
	Status_fl  char(1)
	--,IsNumber bit
)
declare @max int ,@cnt int ,@lstr varchar(200),@tablename varchar(30),@columnname varchar(50)
set nocount on 

--delete @DB_admin where id = 4
insert into @DB_admin (DB_Nme,tablename,columnname,Status_fl )
(select DB_Nme as DB_Nme ,Table_Nme as tablename,Column_Nme as columnname , Status_fl as Status_fl from dbadmin)

--select * from @DB_admin

delete @DB_admin where Status_fl < 1
--select * from @DB_admin

--;with UpdateValues as
--(
	
	
	select 'update '+ db_nme +'.'+ tablename + ' set ' as Prefix,
		STUFF((select columnname + ' = dbo.f_scrambledata(' + columnname + ')'  + ', '
	--' = replace(' + columnname + case when IsNumber = 1 then ', 1, 2)' else ', ''S'', ''t'')' end + ', ' 
		from @DB_admin u2
		where u2.tablename = u1.tablename
		for XML path('')), 1, 0, '') as UpdateColumns
	into #temp22 from @DB_admin u1
	group by tablename, db_nme
--)
-- select Prefix + left(UpdateColumns, LEN(UpdateColumns) - 1)
--from UpdateValues

--sp_executesql(@sqlcmd)

select * from #temp22


select Prefix + left(UpdateColumns, LEN(UpdateColumns) - 1)
from #temp22



DECLARE GET_TABLES CURSOR
READ_ONLY
FOR select Prefix + left(UpdateColumns, LEN(UpdateColumns) - 1)
from #temp21
        
OPEN GET_TABLES
FETCH NEXT FROM GET_TABLES INTO @SQLCMD
WHILE (@@fetch_status = 0)
BEGIN --begin while loop
BEGIN TRY
    --EXEC (@SQLCMD)
   
    set @rowcount = @@rowcount
     set @txt = left(@SQLCMD, 10)
    --report change to user       
   	    SET @INFORMATION = '<<<<< Table [ ' + @SQLCMD + ' ] compatability level = ' + CAST(@rowcount AS varchar) + ' >>>>>';
	    PRINT @INFORMATION;
FETCH NEXT FROM GET_TABLES INTO @SQLCMD;
   END TRY
   BEGIN CATCH
   	   SELECT @ErrorMessage =  'Failed changing comp-level for database ' + @SQLCMD + SPACE(2) + CAST(ERROR_NUMBER() AS NVARCHAR) + SPACE(2) +  ERROR_MESSAGE(),
	          @ErrorSeverity = ERROR_SEVERITY(),
		      @ErrorState = ERROR_STATE();
	    
			RAISERROR (@ErrorMessage, -- Message text.
					   @ErrorSeverity, -- Severity.
					   @ErrorState -- State.
					   );
					   
       FETCH NEXT FROM GET_TABLES INTO @SQLCMD;
   END CATCH;
      
   --
END --end while loop

CLOSE GET_TABLES;
DEALLOCATE GET_TABLES;
GO