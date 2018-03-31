SELECT OBJECT_NAME(object_id), data_compression_desc FROM sys.partitions

ALTER TABLE dbo.CDTypes2 REBUILD PARTITION = ALL
		WITH (DATA_COMPRESSION = PAGE);