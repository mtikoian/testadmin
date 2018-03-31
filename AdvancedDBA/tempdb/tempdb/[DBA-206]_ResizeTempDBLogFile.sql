Declare @LogSizeKB int,
	@TargetSize int,
	@TargetSizeKB int,
	@AlterSizeKB int,
	@LogName sysname,
	@SQL nvarchar(1000);

-- Target size in GB
Set @TargetSize = 8;
Set @TargetSizeKB = @TargetSize*1024*1024;

Select @LogSizeKB = size * 8,
	@LogName = name
From sys.master_files
Where database_id = 2
And type = 1; -- log file

While @LogSizeKB < @TargetSizeKB
  Begin
	Set @AlterSizeKB = @LogSizeKB + 4096000;
	If @AlterSizeKB > @TargetSizeKB
	  Begin
		Set @AlterSizeKB = @TargetSizeKB;
	  End
	
	Set @SQL = N'Alter Database tempdb Modify File
				(Name = N''' + @LogName + ''',
				Size = ' + Cast(@AlterSizeKB As nvarchar) + 'KB);';
	
	Print @SQL;
	
	Exec sp_executesql @SQL;
	
	Select @LogSizeKB = size * 8
	From sys.master_files
	Where database_id = 2
	And type = 1 -- log file
	And name = @LogName;
  End

Select LogName = name,
	LogSizeKB = size * 8
From sys.master_files
Where database_id = 2
And type = 1 -- log file
And name = @LogName;
