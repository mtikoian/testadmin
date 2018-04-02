use master;
go

-- per: http://social.msdn.microsoft.com/Forums/en/sqlreplication/thread/fc6db830-b88d-4248-b887-21fd18d7aea1
-- I had truble during the trial and error stage of setting this up.  I discovered there is a clean up script 
-- that must be run on the subscriber (thus on my one instance since it is both.)  The script is.....  

sp_removedbreplication 
