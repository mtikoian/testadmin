CREATE TRIGGER trg_Replication_Customer ON [dbo].[Customer]  
	FOR DELETE,INSERT,UPDATE   
AS  
BEGIN   
	IF SUSER_SNAME() = 'HPDOCLAPTOP\ReplicationUser' OR SUSER_SNAME() = 'ChangeDataReplication'   
	BEGIN    
		SELECT 1   
	END   
	ELSE   
	BEGIN    
		RAISERROR('Changes Not Allowed on Subscriber Databases', 16, 1)    
		ROLLBACK TRANSACTION   
	DWW
	END  
END  
GO  

USE [distribution]
GO
SELECT 'CREATE TRIGGER trg_Replication_' + a.[Table] + ' ON [' + a.[Schema] + '].[' + a.[Table] + ']
FOR DELETE,INSERT,UPDATE 
AS
BEGIN
	IF SUSER_SNAME() = ''HPDOCLAPTOP\ReplicationUser'' OR SUSER_SNAME() = ''ChangeDataReplication''
	BEGIN
		SELECT 1
	END
	ELSE
	BEGIN
		RAISERROR(''Changes Not Allowed on Subscriber Databases'', 16, 1)
		ROLLBACK TRANSACTION
	END
END
GO
'
FROM (
SELECT
     P.[publication]   AS [Publication Name]
    ,A.[publisher_db]  AS [Database Name]
    ,A.[article]       AS [Article Name]
    ,A.[source_owner]  AS [Schema]
    ,A.[source_object] AS [Table]
FROM
    [distribution].[dbo].[MSarticles] AS A
    INNER JOIN [distribution].[dbo].[MSpublications] AS P
        ON (A.[publication_id] = P.[publication_id])
WHERE P.[publication] = 'Class'
) a
