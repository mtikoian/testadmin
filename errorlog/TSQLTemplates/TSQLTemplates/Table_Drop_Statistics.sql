/*** ================================================================================ Name : . . Author : Description : Revision: $Rev: 189 $ URL: $URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Templates/Table_Add_Index.sql $ Last Checked in: $Author: jfeierman $ =============================================================================== ***/
IF EXISTS (
		SELECT 1
		FROM sys.stats ss
		JOIN sys.objects so ON ss.object_id = so.object_id
		JOIN sys.schemas ssch ON so.schema_id = ssch.schema_id
		WHERE ss.NAME = ''
			AND so.NAME = ' '
			AND ss.NAME = ' '
		)
BEGIN
	DROP STATISTICS..;
END
