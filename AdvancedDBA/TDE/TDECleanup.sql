:CONNECT DEMOVM\S2
use master
go
alter database TESTTDE set encryption OFF
go
DROP DATABASE TESTTDE
GO
DROP certificate MyServerCert
GO
drop master key
GO

:CONNECT DEMOVM\S1
use master
go
alter database TESTTDE set encryption OFF
go
drop database TESTTDE
GO
drop certificate MyServerCert
GO
drop master key
GO
