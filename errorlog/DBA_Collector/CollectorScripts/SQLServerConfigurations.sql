SET NOCOUNT ON

IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1) <> '8'
	SELECT		CAST(configuration_id AS varchar(50)) + '<1>' +
				name + '<2>' +
				description + '<3>' +
				CAST(value AS varchar(50)) + '<4>' +
				CAST(value_in_use AS varchar(50))
	FROM		sys.configurations
ELSE
	SELECT		CAST(config AS varchar(50)) + '<1>' +
				comment + '<2>' +
				comment + '<3>' +
				CAST(value AS varchar(50)) + '<4>' +
				CAST(value AS varchar(50))
	FROM		dbo.sysconfigures