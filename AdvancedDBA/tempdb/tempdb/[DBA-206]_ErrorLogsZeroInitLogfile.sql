Declare @ErrorLog Table (LogID int identity(1, 1) not null primary key,
        LogDate datetime null, 
        ProcessInfo nvarchar(100) null,
        LogText nvarchar(4000) null) 

Insert Into @ErrorLog (LogDate, ProcessInfo, LogText)
Exec master..xp_readerrorlog

Select LogDate, LogText
From @ErrorLog
Where CharIndex('zero', LogText) > 0
And CharIndex('temp', LogText) > 0
Order By LogID Desc 
