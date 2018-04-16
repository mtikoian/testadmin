/*** ================================================================================ Name : . Author : Description : Revision: $Rev$ URL: $URL$ Last Checked in: $Author$ =============================================================================== ***/
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = ' '
			AND TABLE_SCHEMA = ' '
		)
BEGIN
	IF EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE COLUMN_NAME = ''
				AND TABLE_NAME = ' '
				AND TABLE_SCHEMA = ' '
			)
	BEGIN
		ALTER TABLE.

		ALTER COLUMN;
	END
	ELSE
		RAISERROR (
				'Column ''%s'' does not exist on table ''%s.%s''. Aborting.'
				,16
				,1
				,''
				,' '
				,' '
				);
END
ELSE
	RAISERROR (
			'Table ''%s.%s'' does not exist. Aborting.'
			,16
			,1
			,' '
			,' '
			);
	GO
