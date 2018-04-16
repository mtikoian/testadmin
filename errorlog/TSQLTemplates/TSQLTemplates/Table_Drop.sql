/*** ================================================================================ Name : . Author : Description : Drops table  . Revision: $Rev$ URL: $URL$ Last Checked in: $Author$ =============================================================================== Revisions : -------------------------------------------------------------------------------- Ini| Date | Description -------------------------------------------------------------------------------- ================================================================================ ***/
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = ' '
			AND TABLE_SCHEMA = ' '
		)
BEGIN
	DROP TABLE.;

	RAISERROR (
			'Dropped table "%s.%s".'
			,10
			,1
			,' '
			,' '
			)
	WITH NOWAIT;
END
	GO
