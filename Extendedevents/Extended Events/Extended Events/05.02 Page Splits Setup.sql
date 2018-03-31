USE AdventureWorks2014
GO

IF OBJECT_ID('Page_Split_Mania') IS NOT NULL
	DROP TABLE Page_Split_Mania
	
CREATE TABLE Page_Split_Mania
	(
	Id uniqueidentifier default(newid()) PRIMARY KEY CLUSTERED
	,DateValue datetime
	,TheColumn varchar(8000) default (replicate('x', 7900))
	)
GO 

WHILE 1=1
BEGIN
	INSERT into Page_Split_Mania (DateValue) Values(GETDATE())
END
