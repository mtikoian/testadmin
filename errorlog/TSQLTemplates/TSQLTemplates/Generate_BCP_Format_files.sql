--One option:
 DECLARE @sql VARCHAR(4000) 
SET @sql='bcp [Blackjackshared].[dbo].[company] format nul -c -t, -f  d:\myFormat2.fmt -S AG369733\SQLEXPRESS -T'
select @sql
exec master..xp_cmdshell @sql------bcp create non-XML format file


 
--option:2
 DECLARE @sql VARCHAR(4000) 
SET @sql='bcp [Blackjackshared].[dbo].[company] format nul -c  -f  d:\myFormat3.fmt -T -t\t  -S '+ @@servername
select @sql
exec master..xp_cmdshell @sql
 
--Another
 
exec master..xp_cmdshell  'bcp [Blackjackshared].[dbo].[company] format nul   -f  d:\myFormatFile.fmt  -c -T -S AG369733\SQLEXPRESS';
 
go
 
 
------bcp create XML format file
 
----Another Sample:
DECLARE @sql VARCHAR(4000) 
SET @sql='bcp [Blackjackshared].[dbo].[company] format nul -c -x -f  d:\yourFORMATFIle.xml -T  -t\t -S'+ @@servername
exec master..xp_cmdshell @sql
 
 
exec master..xp_cmdshell  'bcp [Blackjackshared].[dbo].[company] format nul -c -x -f  C:\myFormatFile.xml  -T -S myServer\MyInstance';
 
go

 ---Generate xml format file
DECLARE @cmd VARCHAR(4000) 
set @cmd = 'BCP  [testcs].[dbo].[Table_1] format nul   -f "C:\temp\myformatfile.xml" -x -c -t\^",\^" -r \^"\n  -T -S'+ @@servername
exec master..xp_cmdshell @cmd
  
 --Modify the format file myFormatFile.xml  
--By adding one row in the Record section by copy Row ID=1 and change the ID to 0


----bcp in with all data
exec master..xp_cmdshell  'bcp [testcs].[dbo].[Table_1] IN "C:\temp\mytest.txt" -f "C:\temp\myformatfile.xml" -T  -S'+ @@servername;


 