IF ( Object_id('dbo.udf_varbintohexstr_big') IS NOT NULL ) 
  DROP FUNCTION dbo.udf_varbintohexstr_big 

go 

/****************************************************************** 

Author 
====== 
Florian Reischl 

Summary 
======= 
Function to create a hex string of a specified varbinary value. 

Parameters 
========== 

 @pbinin 
 The varbinary to be converted to a hex string. 

Remarks 
======= 
This function is a wrapper for the SQL Server 2005 system function 
master.sys.fn_varbintohexsubstring which is restricted to 3998 bytes 

History 
======= 
V01.00.00 (2009-01-15) 
 * Initial Release 
V01.00.01 (2009-04-01) 
* Fixed bug reported by Robert 
******************************************************************/ 
CREATE FUNCTION dbo.Udf_varbintohexstr_big (@pbinin VARBINARY(max)) 
returns VARCHAR(max) 
AS 
  BEGIN 
      DECLARE @str VARCHAR(max) 
      DECLARE @len INT 
      DECLARE @pos INT 

      SET @str = '0x' 
      SET @len = Datalength(@pbinin) 
      SET @pos = 1 

      IF ( @pbinin IS NULL ) 
        RETURN NULL 

      IF ( @len = 0 ) 
        RETURN '0x0' 

      WHILE ( @pos < @len ) 
        BEGIN 
            DECLARE @offset INT 
            DECLARE @sub VARCHAR(2048) 

            -- Thanks to Robert for bug reporting! 
            SET @offset = @len - @pos 

            IF @offset > 1024 
              SET @offset = 1024 

            SELECT @sub = master.sys.Fn_varbintohexsubstring (0, @pbinin, @pos, 
                          @offset) 

            SET @str = @str + @sub 
            SET @pos = @pos + @offset 
        END 

      RETURN @str 
  END  