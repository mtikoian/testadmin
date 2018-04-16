CREATE FUNCTION dbo.ShowLongString
/**********************************************************************************************************************
 Purpose:
 Display a string of more than 8000 characters.  The string can be Dynamic SQL, XML, or just about anything else.
 Usage:
--===== Example with Dynamic SQL
DECLARE @SQL VARCHAR(MAX);
 SELECT @SQL = '
 SELECT somecolumnlist
   FROM some table with joins
;'
;
 SELECT LongString 
   FROM util.ShowLongString(@SQL)
;
--===== Example with a call to a table or view
 SELECT sm.Object_ID, Definition = ls.LongString 
   FROM sys.SQL_Modules sm
  CROSS APPLY dbo.ShowLongString(sm.Definition) ls
;
Revision History:
Rev 00 - 20 Sep 2013 - Jeff Moden - Initial creation and test.
       - Hats off to Orlando Colamatteo for showing me the trick for this.
**********************************************************************************************************************/
--===== Declare the I/O for this function
        (@pLongString VARCHAR(MAX))
RETURNS TABLE WITH SCHEMABINDING AS
 RETURN
 SELECT LongString =
        (
         SELECT REPLACE(
                    CAST(
                        '--' + CHAR(10) + @pLongString + CHAR(10)
                    AS VARCHAR(MAX))
                ,CHAR(0),'') --CHAR(0) (Null) cannot be converted to XML.
             AS [processing-instruction(LongString)] 
            FOR XML PATH(''), TYPE
        )
;