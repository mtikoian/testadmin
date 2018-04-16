/*** ================================================================================ Name : . Author : Description : Drops trigger  . Revision: $Rev$ URL: $URL$ Last Checked in: $Author$ =============================================================================== Revisions : -------------------------------------------------------------------------------- Ini| Date | Description -------------------------------------------------------------------------------- ================================================================================ ***/
IF EXISTS (
		SELECT 1
		FROM sys.triggers tr
		JOIN sys.objects so ON tr.parent_id = so.object_id
		JOIN sys.schemas ss ON so.schema_id = ss.schema_id
		WHERE tr.NAME = ''
			AND ss.NAME = ' '
		)
BEGIN
	DROP TRIGGER.;

	RAISERROR (
			'Dropped trigger "%s" on "%s.%s".'
			,10
			,1
			,''
			,' '
			,' '
			)
	WITH NOWAIT;
END
	GO
